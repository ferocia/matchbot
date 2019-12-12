# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingEvent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
  let(:game) { create(:game) }
  let(:player_one) { create(:player) }
  let(:player_two) { create(:player) }
  let(:rating_one) { player_one.rating_for_game(game: game) }
  let(:rating_two) { player_two.rating_for_game(game: game) }

  context 'user has played one match' do
    let!(:match_one) do
      Commands::CreateMatch.run(
        game_id: game.id,
        results: [{
          players: [player_one.id], place: 1
        }, {
          players: [player_two.id], place: 2
        }],
      )
    end

    it "should allow a player's first match to be undone" do
      expect(rating_one.reload.mean).to be > game.default_mean
      expect(rating_two.reload.mean).to be < game.default_mean

      expect { match_one.undo! }.to_not raise_error

      expect(rating_one.reload.mean).to eq(game.default_mean)
      expect(rating_two.reload.mean).to eq(game.default_mean)
    end
  end
end
