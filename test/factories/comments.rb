# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    body { "body" }
    association :user
    association :commentable
  end
end
