FactoryBot.define do
  factory :notification, class: Notification do
    association :user
    association :actor, factory: :user
  end
end
