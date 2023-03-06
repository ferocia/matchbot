# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackController, type: :controller do
  def post_with_token(params:)
    ENV['SLACK_WEBHOOK_TOKEN'] = 'test-token' if ENV['SLACK_WEBHOOK_TOKEN'].nil?

    post(
      :webhook,
      params: params.merge(
        token: ENV['SLACK_WEBHOOK_TOKEN'],
        channel_name: 'gaming-rocket-league',
      ),
      as: :json,
    )
  end

  describe 'slack posts' do
    let!(:game) { create(:game, name: 'Rocket League', emoji_name: 'rocket') }
    let!(:player_one) { create(:player, name: 'John') }
    let!(:player_two) { create(:player, name: 'Matthew') }
    let!(:player_three) { create(:player, name: 'Mark') }
    let!(:player_four) { create(:player, name: 'Luke') }

    it 'should process valid slack commands' do
      command = ':rocket: result John+luke:10 matthew+Mark:15'

      post_with_token params: { text: command }

      parsed = JSON.parse(response.body)

      ap parsed

      expect(parsed['username']).to eq('MatchBot')
      expect(parsed['text']).to be_present
    end

    context 'entering a result' do
      before do
        game.ensure_ratings_created_for!([player_one, player_three])

        t1 = Team.find_or_create_by_players([player_one])
        t2 = Team.find_or_create_by_players([player_three])
        m = game.matches.create!(teams: [t1, t2])
        m.results.create!(team: t1, score: 10)
        m.results.create!(team: t2, score: 15)

        m.calculate_ratings_for_players!
      end

      it 'should generate the correct output' do
        command = ":#{game.emoji_name}: result John+luke:10 matthew+Mark:15"

        post_with_token params: { text: command }

        parsed = JSON.parse(response.body)

        expect(parsed['username']).to eq('MatchBot')
        expect(parsed['text']).to eq <<~RES
          *Match Result for Rocket League*

          ```
          1st: Matthew + Mark scored 15.0
          2nd: John + Luke scored 10.0
          ```

          *Player Stats*:

          ```
          Matthew: 2853 (+353)
          Mark: 2641 (+142)
          John: 2358 (-141)
          Luke: 2146 (-354)
          ```
        RES
      end
    end

    context 'for the leaderboard command' do
      before do
        Commands::CreateMatch.run(
          game_id: game.id,
          results: [
            { players: [player_one.id], place: 1 },
            { players: [player_two.id], place: 2 },
            { players: [player_three.id], place: 3 },
            { players: [player_four.id], place: 4 },
          ],
        )

        Commands::CreateMatch.run(
          game_id: game.id,
          results: [
            { players: [player_one.id], place: 1 },
            { players: [player_two.id], place: 2 },
            { players: [player_three.id], place: 3 },
            { players: [player_four.id], place: 4 },
          ],
        )
      end

      it 'generates a leaderboard' do
        command = ":#{game.emoji_name}: leaderboard"
        post_with_token params: { text: command }

        parsed = JSON.parse(response.body)

        expect(parsed['text']).to eq <<~RES
          *Leaderboard for :rocket: Rocket League*

          ```
          +------+---------+------+--------+
          | Rank | Player  | Mean | Played |
          +------+---------+------+--------+
          | 1    | John    | 3618 |      2 |
          | 2    | Matthew | 2822 |      2 |
          | 3    | Mark    | 2177 |      2 |
          | 4    | Luke    | 1381 |      2 |
          +------+---------+------+--------+
          | Played count over last 30 days |
          |       Mean over all time       |
          +------+---------+------+--------+
          ```
        RES
      end
    end
  end
end
