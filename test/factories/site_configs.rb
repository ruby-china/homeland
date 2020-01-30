# frozen_string_literal: true

FactoryBot.define do
  factory :site_config do
    sequence(:key) { |n| "key_#{n}" }
    sequence(:value) { |n| "value_#{n}" }
  end
end
