FactoryGirl.define do
  factory :comment do
    body 'body'
    association :user
    association :commentable, factory: :page
  end
end
