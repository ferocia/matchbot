# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :matches
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
end
