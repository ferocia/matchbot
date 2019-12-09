# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:match) { create(:match) }
  let(:player_one) { create(:player) }
  let(:player_two) { create(:player) }
  let(:player_three) { create(:player) }
  let(:player_four) { create(:player) }
  let(:players) { [player_one, player_two, player_three, player_four] }
  let(:teams) { players.map { |p| Team.find_or_create_by_players([p]) } }

  context 'for a completed match' do
    before do
      match.game.ensure_ratings_created_for!(players)

      results = teams.each_with_index.map do |team, i|
        { team: team, place: i + 1 }
      end

      # insert the results in an abitrary order to ensure it doesn't matter
      match.results.create([results[2], results[0], results[1], results[3]])
      match.calculate_ratings_for_players!
    end

    it 'calculates new ratings correctly' do
      ordered_players = players.map(&:id)

      score_ordered_players = players
        .sort_by { |p| p.ratings.first.mean }
        .reverse # sort gives us smallest first - we want biggest first
        .map(&:id)
      # we assign places in the same order that we generate the players, so
      # these two lists should be the same
      expect(ordered_players).to eq(score_ordered_players)

      rating_one = player_one.rating_for_game(game: match.game).mean.floor
      rating_two = player_two.rating_for_game(game: match.game).mean.floor
      rating_three = player_three.rating_for_game(game: match.game).mean.floor
      rating_four = player_four.rating_for_game(game: match.game).mean.floor

      expect(rating_one).to eq(33)
      expect(rating_two).to eq(27)
      expect(rating_three).to eq(22)
      expect(rating_four).to eq(16)
    end

    it 'generates a correct text response' do
      # should show positions correctly, and output the player stats in the
      # correct order
      expect(match.generate_text_response).to eq <<~RES
        *Match Result for Billiards*

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
      RES
    end
  end
end
