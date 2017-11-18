FactoryBot.define do
  factory :application, class: Doorkeeper::Application do
    sequence(:name) { |n| "name#{n}" }
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:secret) { |n| "secret#{n}" }
    redirect_uri 'http://foobar.com'
    association :owner, factory: :user
  end
end
