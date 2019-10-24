# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackController, type: :controller do
  describe 'slack posts' do
    let!(:game) { create(:game, name: 'Rocket League', emoji: 'rocket') }
    let!(:player_one) { create(:player, name: 'John') }
    let!(:player_two) { create(:player, name: 'Matthew') }
    let!(:player_three) { create(:player, name: 'Mark') }
    let!(:player_four) { create(:player, name: 'Luke') }

    it 'should process valid slack commands' do
      raw_emoji = Emoji.find_by_alias('rocket').raw
      command = "#{raw_emoji} result John+luke:10 matthew+Mark:15"

      post :webhook, params: { text: command }, as: :json

      parsed = JSON.parse(response.body)

      ap parsed

      expect(parsed['username']).to eq('MatchBot')
      expect(parsed['text']).to be_present
    end

    context 'some players have played before' do
      before do
        game.ensure_ratings_created_for!([player_one, player_three])

        t1 = Team.find_or_create_by_players([player_one])
        t2 = Team.find_or_create_by_players([player_three])
        m = game.matches.create!(teams: [t1, t2])
        m.results.create!(team: t1, score: 10)
        m.results.create!(team: t2, score: 15)

        m.calculate_ratings_for_players!
      end
      it 'should show deltas if the players have played before' do
        raw_emoji = Emoji.find_by_alias('rocket').raw
        command = "#{raw_emoji} result John+luke:10 matthew+Mark:15"

        post :webhook, params: { text: command }, as: :json

        parsed = JSON.parse(response.body)

        ap parsed

        expect(parsed['username']).to eq('MatchBot')
        expect(parsed['text']).to be_present
      end
    end
  end
end
