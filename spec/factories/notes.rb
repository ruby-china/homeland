FactoryGirl.define do
  factory :note do
    sequence(:title){|n| "title#{n}" }
    sequence(:body){|n| "body#{n}" }
    association :user
  end
end
