FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "name#{n}" }
  end
end
