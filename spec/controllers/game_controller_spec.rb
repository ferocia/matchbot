# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameController, type: :controller do
  let(:game) { create(:game, name: 'Test Game') }
  let(:player1) { create(:player, name: 'Player 1') }
  let(:player2) { create(:player, name: 'Player 2') }
  let(:player3) { create(:player, name: 'Player 3') }
  let(:player4) { create(:player, name: 'Player 4') }
  let(:team1) { create(:team, players: [player1, player2]) }
  let(:team2) { create(:team, players: [player3, player4]) }
  let(:team3) { create(:team, players: [player2]) }
  let(:team4) { create(:team, players: [player1]) }

  describe 'leaderboard' do
    context 'when matches have been played' do
      before { create_match_fixtures }

      it 'should generate an accurate leaderboard' do
        # get 'leaderboard', params: {id: game.id}, as: :json
        get 'leaderboard', as: :json

        json = JSON.parse(response.body)
        expect(json.map { |o| o['name'] }).to eq(
          [
            'Player 2',
            'Player 1',
            # these two have the same mean, so are sorted alphabetically
            'Player 3',
            'Player 4',
          ],
        )
      end
    end

    context 'when no matches have been played for a game' do
      it 'should be empty' do
        get 'leaderboard', params: { game_name: game.name }, as: :json

        expect(response.body).to eq('[]')
      end
    end
  end

  describe 'matches' do
    context 'when matches have been played' do
      before { create_match_fixtures }

      it 'should get a list of matches' do
        get 'matches', params: { id: game.id }, as: :json
      end
    end
  end

  def create_match_fixtures
    game.ensure_ratings_created_for!([player1, player2, player3, player4])

    m1 = Match.create!(game: game, teams: [team1, team2])
    m1.results.create!(team: team1, score: 20)
    m1.results.create!(team: team2, score: 10)
    m1.calculate_ratings_for_players!

    m2 = Match.create!(game: game, teams: [team3, team4])
    m2.results.create!(team: team3, score: 15)
    m2.results.create!(team: team4, score: 10)
    m2.calculate_ratings_for_players!

    m3 = Match.create!(game: game, teams: [team3, team4])
    m3.results.create!(team: team3, score: 15)
    m3.results.create!(team: team4, score: 10)
    m3.calculate_ratings_for_players!
  end
end
