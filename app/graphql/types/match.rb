# frozen_string_literal: true

class Types::Match < Types::Base::Object
  field :id, ID, null: false
  field :createdAt, Float, null: false
  field :game, Types::Game, null: false

  field :ratingEvents, [Types::RatingEvent], null: false
  field :results, [Types::Result], null: false

  def game
    Loaders::Record.for(Game).load(object.game_id)
  end

  def rating_events
    Loaders::Association.for(Match, :rating_events).load(object).then do
      object.rating_events
    end
  end

  def results
    Loaders::Association.for(Match, :results).load(object).then do
      object.results
    end
  end
end
