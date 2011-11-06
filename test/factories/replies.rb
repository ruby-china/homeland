FactoryGirl.define do
  factory :reply do
    body 'body'
    association :user
    association :topic
  end
end
