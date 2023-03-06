# frozen_string_literal: true

class Player < ApplicationRecord
  has_many :ratings, dependent: :destroy
  has_many :rating_events, through: :ratings
  has_and_belongs_to_many :teams, join_table: :players_teams

  def trueskill_for_game(game:)
    rating = rating_for_game(game: game)
    Saulabs::TrueSkill::Rating.new(rating.mean, rating.deviation)
  end

  def rating_for_game(game:)
    ratings.find_by(game: game)
  end

  def generate_text_response_for(match:)
    current, previous =
      rating_events.joins(:match).where(matches: { game_id: match.game_id })
        .order(created_at: :desc)
        .limit(2)

    delta = if previous.present?
              (current.public_mean - previous.public_mean)
            else
              (current.public_mean - (match.game.default_mean * 100))
            end.to_i

    delta_text =
      if delta == 0
        '--'
      elsif delta > 0
        "+#{delta}"
      else
        delta
      end

    "#{name}: #{current.public_mean} (#{delta_text})"
  end
end
