FactoryGirl.define do
  factory :device do
    kind 1
    association :user
    token { SecureRandom.hex }
  end
end
