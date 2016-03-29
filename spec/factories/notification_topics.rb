FactoryGirl.define do
  factory :notification_topic, class: Notification, parent: :notification_base do
    association :topic
  end
end
