FactoryGirl.define do
  factory :notification_topic, class: Notification::Topic, parent: :notification_base do
    association :topic
  end
end
