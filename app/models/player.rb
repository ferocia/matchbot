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
end
