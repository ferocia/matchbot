# frozen_string_literal: true

class Types::Player < Types::Base::Object
  field :id, ID, null: false
  field :name, String, null: false
  field :ratings, [Types::Rating], null: false
  field :rating, Types::Rating, null: true do
    argument :game_id, ID, required: true
  end

  def ratings
    Loaders::Association.for(Player, :ratings).load(object).then do
      object.ratings
    end
  end

  def rating(game_id:)
    game = Game.find(game_id)

    ratings.then do |rts|
      rts.find_by(game: game)
    end
  end
end
