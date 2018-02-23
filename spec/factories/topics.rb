# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    title "title"
    body "body"
    association :user
    association :node
  end
end
