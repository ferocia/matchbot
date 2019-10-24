# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchController, type: :controller do
  describe 'match creation' do
    let(:game) { create(:game, name: 'Game 1') }
    let(:player1) { create(:player, name: 'Player 1') }
    let(:player2) { create(:player, name: 'Player 2') }
    let(:player3) { create(:player, name: 'Player 3') }
    let(:player4) { create(:player, name: 'Player 4') }
    let(:team1) { create(:team, players: [player1, player2]) }
    let(:team2) { create(:team, players: [player3, player4]) }

    it 'should create a match correctly' do
      params = {
        game_name: game.name,
        scores: [
          { players: team1.players.map(&:id), score: 10 },
          { players: team2.players.map(&:id), score: 40 },
        ],
      }

      post :create, params: params, as: :json

      expect(response.body).to eq(
        {
          game_name: game.name,
          results: [
            { team: [player3.name, player4.name], score: 40.0 },
            { team: [player1.name, player2.name], score: 10.0 },
          ],
        }.to_json,
      )
    end

    it "should create the team if it doesn't yet exist" do
      params = {
        game_name: game.name,
        scores: [
          { players: team1.players.map(&:id), score: 30 },
          { players: [player3.id, player4.id], score: 10 },
        ],
      }

      expect(Team.count).to eq(1)
      post :create, params: params, as: :json

      expect(Team.count).to eq(2)

      expect(response.body).to eq(
        {
          game_name: game.name,
          results: [
            { team: [player1.name, player2.name], score: 40.0 },
            { team: [player3.name, player4.name], score: 10.0 },
          ],
        }.to_json,
      )
    end
  end
end
