# frozen_string_literal: true

class RatingEvent < ApplicationRecord
  belongs_to :rating
  belongs_to :match
end
