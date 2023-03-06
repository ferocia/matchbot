# frozen_string_literal: true

class Mutations::CreatePlayer < Mutations::Base::Mutation
  argument :name, String, required: true

  field :player, Types::Player, null: true
  field :errors, [String], null: true

  def resolve(name:)
    player = Commands::CreatePlayer.run(name: name)

    { player: player }
  rescue ActiveRecord::RecordNotUnique
    { errors: ['Player already exists with that name'] }
  end
end
