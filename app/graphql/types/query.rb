# frozen_string_literal: true

class Types::Query < Types::Base::Object
  field :games, [Types::Game], null: false
  field :game, Types::Game, null: true do
    argument :id, ID, required: true
  end

  field :players, [Types::Player], null: false
  field :player, Types::Player, null: true do
    argument :id, ID, required: true
  end

  def games
    ::Game.all
  end

  def game(id:)
    ::Game.find(id)
  end

  def players
    ::Player.all
  end

  def player(id:)
    Loaders::Record.for(Player).load(id.to_i)
  end
end
