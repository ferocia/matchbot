# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :player
  belongs_to :game
  has_many :rating_events, dependent: :destroy

  scope :recent, (lambda do
    where('updated_at BETWEEN ? AND ?', 30.days.ago, Time.now)
  end)

  def public_mean
    (mean * 100).floor
  end

  def reset_to_last_event!
    mean = nil
    deviation = nil

    event = rating_events.order(updated_at: :desc).first

    if event.present?
      mean = event.mean
      deviation = event.deviation
    else
      mean = game.default_mean
      deviation = game.default_deviation
    end

    update!(mean: mean, deviation: deviation)
  end
end
