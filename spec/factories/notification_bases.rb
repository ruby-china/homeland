FactoryGirl.define do
  factory :notification, class: Notification do
    association :user
  end
end
