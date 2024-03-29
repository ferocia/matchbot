# frozen_string_literal: true

class Types::Rating < Types::Base::Object
  field :id, ID, null: false
  field :mean, Float, null: false
  field :deviation, Float, null: false
  field :updated_at, Float, null: false

  field :player, Types::Player, null: false
  field :game, Types::Game, null: false

  field :rating_events, [Types::RatingEvent], null: false
  field :play_count, Int, null: false

  def mean
    object.public_mean
  end

  def player
    Loaders::Record.for(Player).load(object.player_id)
  end

  def game
    Loaders::Record.for(Game).load(object.game_id)
  end

  def rating_events
    Loaders::Association.for(Rating, :rating_events).load(object).then do
      object.rating_events
    end
  end

  def play_count
    rating_events.then(&:count)
  end
end
