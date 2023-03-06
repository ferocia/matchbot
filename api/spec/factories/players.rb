# frozen_string_literal: true

FactoryBot.define do
  sequence :player_name do |n|
    "Player #{n}"
  end
  factory :player do
    name { generate(:player_name) }
  end
end
