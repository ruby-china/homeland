# frozen_string_literal: true

FactoryBot.define do
  factory :reply do
    sequence(:body) { |n| "body#{n}" }
    association :user
    association :topic
  end
end
