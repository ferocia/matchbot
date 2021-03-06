# frozen_string_literal: true

class Types::Team < Types::Base::Object
  field :id, ID, null: false
  field :players, [Types::Player], null: false
end
