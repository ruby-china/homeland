# frozen_string_literal: true

FactoryBot.define do
  factory :notification, class: Notification do
    notify_type { "foo" }
    association :user
    association :actor, factory: :user
  end
end
