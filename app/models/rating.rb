# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :player
  belongs_to :game
  has_many :rating_events, dependent: :destroy
end
