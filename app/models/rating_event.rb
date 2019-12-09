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

      if previous_event.nil?
        raise StandardError, "Can't undo because no previous event"
      end

      rating.update!(
        mean: previous_event.mean,
        deviation: previous_event.deviation,
      )

      # remove this rating
      destroy
    end
  end
end
