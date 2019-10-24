# frozen_string_literal: true

class Mutations::CreateMatch < Mutations::Base::Mutation
  class MatchResult < Types::Base::InputObject
    argument :players, [ID], required: true
    argument :score, Float, required: true
  end

  argument :gameId, ID, required: true
  argument :results, [MatchResult], required: true

  field :match, Types::Match, null: true
  field :errors, [String], null: true

  def resolve(game_id:, results:)
    match = Commands::CreateMatch.run(
      game_id: game_id,
      results: results.map(&:to_h),
    )

    { match: match }
  end
end
