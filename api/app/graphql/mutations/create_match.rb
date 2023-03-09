# frozen_string_literal: true

class Mutations::CreateMatch < Mutations::Base::Mutation
  class MatchResult < Types::Base::InputObject
    argument :players, [ID], required: true
    argument :score, Float, required: false
    argument :place, Integer, required: false
  end

  argument :game_id, ID, required: true
  argument :results, [MatchResult], required: true
  argument :post_result_to_slack, Boolean, required: false, default_value: false

  field :match, Types::Match, null: true
  field :errors, [String], null: true

  def resolve(game_id:, results:, post_result_to_slack:)
    match = Commands::CreateMatch.run(
      game_id: game_id,
      results: results.map(&:to_h),
    )

    post_to_slack(game_id:, match:) if post_result_to_slack == true

    { match: match }
  end

  private

  def post_to_slack(game_id:, match:)
    match_response = match.generate_text_response

    game = Game.find(game_id)

    Commands::PostToSlack.run(
      channel_id: game.slack_channel_id,
      text: match_response,
    )
  end
end
