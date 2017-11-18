FactoryBot.define do
  factory :topic do
    title 'title'
    body 'body'
    association :user
    association :node
  end
end
