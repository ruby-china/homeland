FactoryBot.define do
  factory :notification_topic, parent: :notification do
    notify_type 'topic'
    association :target, factory: :topic
  end
end
