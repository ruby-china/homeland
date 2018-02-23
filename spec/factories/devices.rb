# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    platform 1
    association :user
    token { SecureRandom.hex }
  end
end
