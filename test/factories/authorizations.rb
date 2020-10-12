# frozen_string_literal: true

FactoryBot.define do
  factory :authorization do
    provider { "github" }
    sequence(:uid) { |n| "github-#{n}" }
    association(:user)
  end
end
