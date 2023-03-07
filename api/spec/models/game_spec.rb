# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  describe '#ensure_ratings_created_for!' do
    let(:default_mean) { 10 }
    let(:default_deviation) { 3 }
    let(:game) do
      create(
        :game,
        default_mean: default_mean, default_deviation: default_deviation,
      )
    end
    let(:player) { create(:player, name: 'Player 1') }
    let(:player2) { create(:player, name: 'Player 2') }
    context 'player has never played the game before' do
      it 'should create a rating with the default values' do
        expect(player.ratings.find_by(game: game)).to be_nil

        game.ensure_ratings_created_for!(player)

        r = player.ratings.find_by(game: game)
        expect(r).to_not be_nil
        expect(r.mean).to eq(default_mean)
        expect(r.deviation).to eq(default_deviation)
      end
    end

    context 'player has played the game before' do
      it 'should not change the existing rating' do
        mean = 7
        deviation = 1
        player.ratings.create!(game: game, mean: mean, deviation: deviation)
        game.ensure_ratings_created_for!(player)

        r = player.ratings.find_by(game: game)
        expect(r.mean).to eq(mean)
        expect(r.deviation).to eq(deviation)
      end
    end

    it 'works for mutltiple players at a time' do
      game.ensure_ratings_created_for!([player, player2])

      expect(player.ratings.find_by(game: game)).to_not be_nil
      expect(player2.ratings.find_by(game: game)).to_not be_nil
    end
  end
end
