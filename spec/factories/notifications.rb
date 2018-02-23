# frozen_string_literal: true

FactoryBot.define do
  factory :notification, class: Notification do
    association :user
    association :actor, factory: :user
  end
end
