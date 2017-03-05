FactoryGirl.define do
  factory :comment do
    body 'body'
    association :user
    association :commentable
  end
end
