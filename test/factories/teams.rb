# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    sequence(:login) { |n| "team#{n}" }
    sequence(:email) { |n| "team#{n}@gethomeland.com" }
  end
end
