# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    sequence(:title) { |n| "Topic Title #{n}" }
    sequence(:body) { |n| "Topic Body #{n}" }
    sequence(:draft) { |n| false }
    association :user
    association :node
  end
end
