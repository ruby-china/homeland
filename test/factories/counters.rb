# frozen_string_literal: true

FactoryBot.define do
  factory :counter do
    association :countable, factory: :user
    key { "foo_count" }
    value { 0 }
  end
end
