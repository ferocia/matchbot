# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:match) { create(:match) }
  let(:player_one) { create(:player, name: 'abby') }
  let(:player_two) { create(:player, name: 'barry') }
  let(:player_three) { create(:player, name: 'celeste') }
  let(:player_four) { create(:player, name: 'don') }
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
        1st: abby    | 3320 (+820)
        2nd: barry   | 2740 (+240)
        3rd: celeste | 2259 (-241)
        4th: don     | 1679 (-821)
        ```
      RES
    end
  end

  context 'for a team match' do
    let(:teams) { [
      Team.find_or_create_by_players(players[0..1]),
      Team.find_or_create_by_players(players[2..3])
    ]}

    before do
      match.game.ensure_ratings_created_for!(players)

      results = teams.each_with_index.map do |team, i|
        { team: team, place: i + 1 }
      end

      # insert the results in an abitrary order to ensure it doesn't matter
      match.results.create([results[1], results[0]])
      match.calculate_ratings_for_players!
    end

    it 'generates correct text response' do
      expect(match.generate_text_response).to eq <<~RES
        *Match Result for Billiards*

        ```
        1st: abby + barry
        2nd: celeste + don
        ```

        *Player Stats*:

        ```
        abby: 2806 (+306)
        barry: 2806 (+306)
        celeste: 2193 (-307)
        don: 2193 (-307)
        ```
      RES
    end
  end

  context 'for a scored match' do
    before do
      match.game.ensure_ratings_created_for!(players)

      results = teams.each_with_index.map do |team, i|
        { team: team, place: i + 1, score: i }
      end

      # insert the results in an abitrary order to ensure it doesn't matter
      match.results.create([results[2], results[0], results[1], results[3]])
      match.calculate_ratings_for_players!
    end

    it 'generates correct text response' do
      expect(match.generate_text_response).to eq <<~RES
        *Match Result for Billiards*

        ```
        1st: abby scored 0.0    | 3320 (+820)
        2nd: barry scored 1.0   | 2740 (+240)
        3rd: celeste scored 2.0 | 2259 (-241)
        4th: don scored 3.0     | 1679 (-821)
        ```
      RES
    end
  end
end
