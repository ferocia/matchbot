# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateMatch, type: :model do
  let(:game) { create(:game) }
  let(:player_one) { create(:player) }
  let(:player_two) { create(:player) }
  let(:player_three) { create(:player) }
  let(:player_four) { create(:player) }

  it 'should create a new match' do
    query = <<~GQL
      mutation CreateMatch($gameId: ID!, $results: [MatchResult!]!) {
        createMatch(gameId: $gameId, results: $results) {
          match { id }
        }
      }
    GQL

    result = execute(query, variables: { gameId: game.id, results: [
      { players: [player_one.id], place: 1 },
      { players: [player_two.id], place: 2 },
      { players: [player_three.id], place: 3 },
      { players: [player_four.id], place: 4 },
    ] })

    expect(result['data']['createMatch']['match']['id']).to be_present
  end

  context 'when asked to post to slack' do
    let(:game) { create(:game, name: 'Super Smash Bros') }

    webhook_url = 'https://slack.com/webhook'

    it 'should post a result to slack' do
      ENV['SMASH_OUTGOING_SLACK_HOOK'] = webhook_url
      stub_request(:any, webhook_url)

      query = <<~GQL
        mutation CreateMatch($gameId: ID!, $results: [MatchResult!]!) {
          createMatch(gameId: $gameId, results: $results, postResultToSlack: true) {
            match { id }
          }
        }
      GQL

      result = execute(query, variables: { gameId: game.id, results: [
        { players: [player_one.id], place: 1 },
        { players: [player_two.id], place: 2 },
        { players: [player_three.id], place: 3 },
        { players: [player_four.id], place: 4 },
      ] })

      text = <<~RES
        *Match Result for Super Smash Bros*

        ```
        1st: #{player_one.name}
        2nd: #{player_two.name}
        3rd: #{player_three.name}
        4th: #{player_four.name}
        ```

        *Player Stats*:

        ```
        #{player_one.name}: 3320 (+820)
        #{player_two.name}: 2740 (+240)
        #{player_three.name}: 2259 (-241)
        #{player_four.name}: 1679 (-821)
        ```


        *Leaderboard*

        ```
        +------+----------+------+--------+
        | Rank | Player   | Mean | Played |
        +------+----------+------+--------+
        | 1    | #{player_one.name} | 3320 |      1 |
        | 2    | #{player_two.name} | 2740 |      1 |
        | 3    | #{player_three.name} | 2259 |      1 |
        | 4    | #{player_four.name} | 1679 |      1 |
        +------+----------+------+--------+
        | Played count over last 30 days  |
        |       Mean over all time        |
        +------+----------+------+--------+
        ```
      RES

      expect(result['data']['createMatch']['match']['id']).to be_present
      expect(WebMock).to have_requested(:post, webhook_url).with(body: {
        text: text,
      }.to_json)
    end
  end
end
