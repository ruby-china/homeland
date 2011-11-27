FactoryGirl.define do
  factory :notification_mention, :class => Notification::Mention, :parent => :notification_base do
    association :reply
  end
end
