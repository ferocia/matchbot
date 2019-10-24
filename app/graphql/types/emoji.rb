# frozen_string_literal: true

class Types::Emoji < Types::Base::Object
  field :name, String, null: false
  field :raw, String, null: false
end
