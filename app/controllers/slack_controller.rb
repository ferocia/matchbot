# frozen_string_literal: true

class SlackController < ApplicationController
  def webhook
    body = parsed_body

    ap body

    game = Game.find_by_emoji(body[:emoji])
    raise StandardError, "Can't find game with emoji \`#{content}\`" unless game

    all_players = body[:results].map { |r| r[:players] }.flatten

    game.ensure_ratings_created_for!(all_players)

    m = Match.create!(game: game, teams: body[:results].map { |r| r[:team] })

    body[:results].each do |result|
      m.results.create!(team: result[:team], score: result[:score])
    end

    m.calculate_ratings_for_players!

    render json: { text: generate_response_for_match(m), username: 'MatchBot' }
  end

  private

  def parsed_body
    body = params.require(:text)
    split = body.split(' ')
    emoji = split.first
    # the only support command is 'result'
    first_result = parse_result(split.third)
    second_result = parse_result(split.fourth)

    { emoji: emoji, results: [first_result, second_result] }
  end

  # result looks like 'Name+Name:Score'
  def parse_result(result)
    names, score_string = result.split(':')
    score = score_string.to_f
    names = names.split('+')

    players =
      names.map do |name|
        player = Player.find_by('name ilike ?', name)
        raise StandardError, "No player with name \`#{name}\`" unless player

        player
      end

    team = Team.find_or_create_by_players(players)

    { score: score, players: players, team: team }
  end

  def generate_response_for_match(match)
    <<~RES
      **Match Result for #{match.game.name}**
      ```
      #{
        match.results.map do |r, _i|
          "#{r.team.players.map(&:name).join(' + ')} scored #{r.score}"
        end.join("\n")
      }
      ```
      **Player Stats**:
      ```
      #{
        match.players.map { |p| generate_player_text(match, p) }.join("\n")
      }
      ```
    RES
  end

  def generate_player_text(match, player)
    current, previous =
      player.rating_events.joins(:match).where(
        matches: { game_id: match.game_id },
      )
        .order(created_at: :desc)
        .limit(2)
    return "#{player.name}: #{current.mean.round(4)}" if previous.nil?

    delta = (current.mean - previous.mean).round(4)

    delta_text =
      if delta == 0
        '-'
      elsif delta > 0
        "+#{delta}"
      else
        delta
      end

    "#{player.name}: #{current.mean.round(4)} (#{delta_text})"
  end
end
