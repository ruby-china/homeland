FactoryGirl.define do
  factory :notification_topic_reply, class: Notification, parent: :notification_base do
    association :reply
  end
end
