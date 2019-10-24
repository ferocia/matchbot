# frozen_string_literal: true

class Types::Player < Types::Base::Object
  field :id, ID, null: false
  field :name, String, null: false
  field :ratings, [Types::Rating], null: false

  def ratings
    Loaders::Association.for(Player, :ratings).load(object).then do
      object.ratings
    end
  end
end
