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

    it 'should post a result to slack' do
      query = <<~GQL
        mutation CreateMatch($gameId: ID!, $results: [MatchResult!]!) {
          createMatch(gameId: $gameId, results: $results, postResultToSlack: true) {
            match { id }
          }
        }
      GQL

      expect(Commands::PostToSlack).to receive(:run)
        .with(channel_id: game.slack_channel_id, text: /Match Result for/)

      result = execute(query, variables: { gameId: game.id, results: [
        { players: [player_one.id], place: 1 },
        { players: [player_two.id], place: 2 },
        { players: [player_three.id], place: 3 },
        { players: [player_four.id], place: 4 },
      ] })

      expect(result['data']['createMatch']['match']['id']).to be_present
    end
  end
end
