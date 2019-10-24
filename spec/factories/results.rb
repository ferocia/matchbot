# frozen_string_literal: true

FactoryBot.define do
  factory :result do
    match { nil }
    team { nil }
    score { 1.5 }
  end
end
