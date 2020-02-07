# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :matches
  has_many :rating_events, through: :matches
  has_many :results, through: :matches
  has_many :ratings

  def self.find_by_emoji(emoji)
    parsed = Emoji.find_by_unicode(emoji)
    raise ArgumentError, "Couldn't find emoji for #{emoji}" unless parsed

    name = parsed.name
    find_by(emoji_name: name)
  end

  def emoji
    Emoji.find_by_alias(emoji_name)
  end

  def ensure_ratings_created_for!(players)
    players = [players] unless players.respond_to?(:each)
    players.each do |player|
      rating = player.ratings.find_by(game_id: id)
      next unless rating.nil?

      Rating.create!(
        player: player,
        game_id: id,
        mean: default_mean,
        deviation: default_deviation,
      )
    end
  end

  def generate_text_leaderboard
    headings = %w[Rank Player Mean Played]

    rows = ratings
      .recent
      .includes(:player)
      .includes(:rating_events)
      .where('ratings.updated_at BETWEEN ? and ?', 30.days.ago, Time.now)
      .order(mean: :desc)
      .each_with_index
      .map do |rating, i|
        played = rating.rating_events
          .where('updated_at BETWEEN ? AND ?', 30.days.ago, Time.now)
          .count

        # If you add something here, make sure you update the headings as well
        [
          i + 1,
          rating.player.name,
          rating.public_mean,
          { value: played, alignment: :right },
        ]
      end

    # add the footer
    rows << :separator
    rows << [{
      value: 'Played count over last 30 days',
      alignment: :center,
      colspan: headings.length,
    }]
    rows << [{
      value: 'Mean over all time',
      alignment: :center,
      colspan: headings.length,
    }]

    Terminal::Table.new(
      headings: headings,
      rows: rows,
    ).to_s
  end
end
