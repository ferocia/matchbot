# frozen_string_literal: true

class Mutations::CreateMatch < Mutations::Base::Mutation
  class MatchResult < Types::Base::InputObject
    argument :players, [ID], required: true
    argument :score, Float, required: false
    argument :place, Integer, required: false
  end

  argument :gameId, ID, required: true
  argument :results, [MatchResult], required: true
  argument :postResultToSlack, Boolean, required: false, default_value: false

  field :match, Types::Match, null: true
  field :errors, [String], null: true

  def resolve(game_id:, results:, post_result_to_slack:)
    match = Commands::CreateMatch.run(
      game_id: game_id,
      results: results.map(&:to_h),
    )

    post_to_slack(match: match) if post_result_to_slack == true

    { match: match }
  end

  private

  def post_to_slack(match:)
    webhook_url = case match.game.name
                  when 'Super Smash Bros'
                    ENV['SMASH_OUTGOING_SLACK_HOOK']
                  when '9 Ball', '8 Ball'
                    ENV['BILLIARDS_OUTGOING_SLACK_HOOK']
                  end

    return unless webhook_url.present?

    match_response = match.generate_text_response
    leaderboard = match.game.generate_text_leaderboard

    text = <<~RES
      #{match_response}

      *Leaderboard*

      ```
      #{leaderboard}
      ```
    RES

    Commands::PostToSlack.run(
      webhook_url: webhook_url,
      message: text,
    )
  end
end
