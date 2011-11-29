FactoryGirl.define do
  factory :comment do
    body 'body'
    association :user
    commentable nil
  end
end
