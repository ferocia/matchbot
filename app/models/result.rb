# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :match
  belongs_to :team
end
