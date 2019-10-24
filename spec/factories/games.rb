# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    name { 'Billiards' }
    default_mean { 25 }
    default_deviation { 25.0 / 3 }
    emoji_name { '8ball' }
  end
end
