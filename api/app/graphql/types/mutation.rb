# frozen_string_literal: true

class Types::Mutation < Types::Base::Object
  field :create_match, mutation: Mutations::CreateMatch
  field :create_game, mutation: Mutations::CreateGame
  field :create_player, mutation: Mutations::CreatePlayer
end
