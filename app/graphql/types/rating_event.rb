# frozen_string_literal: true

class Types::RatingEvent < Types::Base::Object
  field :id, ID, null: false
  field :mean, Float, null: false
  field :deviation, Float, null: false
  field :deltaMean, Float, null: true
  field :deltaDeviation, Float, null: true

  field :rating, Types::Rating, null: false

  def rating
    Loaders::Record.for(Rating).load(object.rating_id)
  end

  def delta_mean
    previous_rating_event.then do |event|
      object.mean - event.mean if event.present?
    end
  end

  def delta_deviation
    previous_rating_event.then do |event|
      object.deviation - event.deviation if event.present?
    end
  end

  private

  def previous_rating_event
    Loaders::Record.for(Rating).load(object.rating_id).then do |rating|
      # this could definitely be optimized
      rating.rating_events
        .order(updated_at: :desc)
        .find_by('updated_at < ?', object.updated_at)
    end
  end
end
