FactoryBot.define do
  factory :node do
    sequence(:name) { |n| "name#{n}" }
    summary { "summary" }
  end
end
