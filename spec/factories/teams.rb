# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    players { [create(:player), create(:player)] }
  end
end
