# frozen_string_literal: true

FactoryBot.define do
  factory :notification_topic_reply, parent: :notification do
    notify_type { "topic_reply" }
    association :target, factory: :reply
    association :second_target, factory: :topic
  end
end
