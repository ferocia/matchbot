# frozen_string_literal: true

class RatingEvent < ApplicationRecord
  belongs_to :rating
  belongs_to :match

  def public_mean
    (mean * 100).floor
  end

  def undo!
    ActiveRecord::Base.transaction do
      previous_event = rating.rating_events
        .where('updated_at < ?', updated_at)
        .order(updated_at: :desc)
        .first

      after = rating.rating_events.where('updated_at > ?', updated_at).count
      if after > 0
        raise StandardError, "Can't undo because there are matches after this"
      end

      if previous_event.nil?
        game = match.game
        rating.update!(
          mean: game.default_mean,
          deviation: game.default_deviation,
        )
      else
        rating.update!(
          mean: previous_event.mean,
          deviation: previous_event.deviation,
        )
      end

      # remove this rating
      destroy
    end
  end
end
