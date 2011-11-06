FactoryGirl.define do
  factory :notification_base, :class => Notification::Base do
    association :user
  end
end
