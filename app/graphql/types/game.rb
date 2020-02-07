# frozen_string_literal: true

class Types::Game < Types::Base::Object
  field :id, ID, null: false
  field :name, String, null: false
  field :defaultMean, Float, null: false
  field :defaultDeviation, Float, null: false
  field :emoji, Types::Emoji, null: false

  field :leaderboard, [Types::Rating], null: false
  field :matches, [Types::Match], null: false

  def leaderboard
    object.ratings.recent.order(mean: :desc)
  end

  def matches
    Loaders::Association.for(Game, :matches).load(object).then do
      object.matches
    end
  end
end
