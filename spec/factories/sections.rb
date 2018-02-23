# frozen_string_literal: true

FactoryBot.define do
  factory :section do
    sequence(:name) { |n| "name#{n}" }
  end
end
