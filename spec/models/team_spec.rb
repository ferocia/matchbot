# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe '.find_by_players' do
    let(:game) { create(:game, name: 'Game 1') }
    let(:player1) { create(:player, name: 'Player 1') }
    let(:player2) { create(:player, name: 'Player 2') }
    let(:player3) { create(:player, name: 'Player 3') }
    let!(:team1) { create(:team, players: [player1]) }
    let!(:team2) { create(:team, players: [player1, player2]) }
    let!(:team3) { create(:team, players: [player2, player3]) }

    it 'should find a team for given players' do
      team = Team.find_by_players([player1, player2])

      expect(team).to eq(team2)
    end

    it 'should get the a team of 1' do
      team = Team.find_by_players([player1])

      expect(team).to eq(team1)
    end
  end
end
