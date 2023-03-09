# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    name { 'Billiards' }
    default_mean { 25 }
    default_deviation { 25.0 / 3 }
    emoji_name { '8ball' }
    slack_channel_id { 'C12345678' }
  end
end
