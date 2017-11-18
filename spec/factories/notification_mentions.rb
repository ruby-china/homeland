FactoryBot.define do
  factory :notification_mention, parent: :notification do
    notify_type 'mention'
    association :target, factory: :reply
    association :second_target, factory: :topic
  end
end
