# frozen_string_literal: true

FactoryBot.define do
  factory :photo do
    association :user
  end
end
