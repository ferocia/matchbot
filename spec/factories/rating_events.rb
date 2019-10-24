# frozen_string_literal: true

FactoryBot.define do
  factory :rating_event do
    rating { nil }
    match { nil }
    mean { 1.5 }
    deviation { 1.5 }
  end
end
