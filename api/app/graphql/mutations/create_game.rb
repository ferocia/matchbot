# frozen_string_literal: true

class Mutations::CreateGame < Mutations::Base::Mutation
  argument :name, String, required: true
  argument :emoji, String, required: true

  field :game, Types::Game, null: true
  field :errors, [String], null: true

  def resolve(name:, emoji:)
    game = Commands::CreateGame.run(
      name: name,
      emoji: emoji,
    )

    { game: game }
  rescue StandardError => e
    { errors: [e.message] }
  end
end
