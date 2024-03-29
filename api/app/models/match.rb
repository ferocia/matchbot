# frozen_string_literal: true

class Match < ApplicationRecord
  belongs_to :game

  has_many :results
  has_many :rating_events
  has_many :teams, through: :results
  has_many :players, through: :teams

  def calculate_ratings_for_players!
    # if this match has rating events, we don't want to re-calc
    return if rating_events.present?

    places = []
    ratings = []
    trueskills = []

    results.order(place: :asc).each do |result|
      r = result.team.players.map { |p| p.rating_for_game(game: game) }
      t = result.team.players.map { |p| p.trueskill_for_game(game: game) }

      ratings << r
      trueskills << t
      places << result.place
    end

    # this gets us a hash, { [[TrueSkill::Rating]]: place }
    graph_input = trueskills.each_with_index.map do |trueskill, i|
      [trueskill, places[i]]
    end.to_h

    graph = Saulabs::TrueSkill::FactorGraph.new(graph_input)
    # this _mutates_ the hash passed in
    graph.update_skills

    # wrap in a txn to roll back updates if something goes wrong :|
    ActiveRecord::Base.transaction do
      # now, teams is a list of updated ratings. we need to map these back to
      # the teams, based on the index, and then the players inside, based on the
      # sub-index, to attribute a new rating back to a player
      trueskills.each_with_index do |trueskill, i|
        rating = ratings[i]

        trueskill.zip(rating).each do |ts, player_rating|
          rating_events.create!(
            rating: player_rating,
            mean: ts.mean,
            deviation: ts.deviation,
          )

          player_rating.update!(
            mean: ts.mean,
            deviation: ts.deviation,
          )
        end
      end
    end
  end

  def undo!
    ActiveRecord::Base.transaction do
      rating_events.each(&:undo!)

      results.destroy_all

      destroy
    end
  end

  def generate_text_response
    ordered_results = results.order(place: :asc)
    team_game = ordered_results.any? {|x| x.team.players.size > 1 }

    table = ordered_results.map do |r|
      columns = []
      columns << begin
        s = "#{r.place.ordinalize}: #{r.team.players.map(&:name).join(' + ')}"
        if r.score.present?
          "#{s} (#{format_score(r.score)})"
        else
          s
        end
      end
      if !team_game
        columns <<
          r.team.players.first.generate_text_response_for(
            match: self,
            include_name: false
          )
      end
      columns
    end

    column_widths = table.transpose.map {|c| c.map(&:length).max }

    result = <<~RES
      *Match Result for #{game.name}*

      ```
      #{
        table.map {|row|
          row.zip(column_widths).map {|r, w| "%-#{w}s" % r }.join(" | ").strip
        }.join("\n")
      }
      ```
    RES

    if team_game
      result += <<~RES

        *Player Stats*:

        ```
        #{
          ordered_results
            .map { |r| r.team.players }
            .flatten
            .map { |p| p.generate_text_response_for(match: self) }
            .join("\n")
        }
        ```
      RES
    end

    result
  end

  def generate_web_response
    ordered_results = results.order(place: :asc)

    <<~RES
      Match Result for #{game.name}:
      #{
        ordered_results.map do |r, _i|
          s = "#{r.place.ordinalize}: #{r.team.players.map(&:name).join(' + ')}"
          if r.score.present?
            "#{s} scored #{r.score}"
          else
            s
          end
        end.join(", ")
      }
    RES
  end

  private

  def format_score(x)
    if x.to_i == x
      x.to_i
    else
      x
    end.to_s
  end
end
