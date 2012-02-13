# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site do
    sequence(:name) { |n| "name #{n}" }
    sequence(:url) { |n| "http://awesome-site-no-#{n}.com" }
    sequence(:title) { |n| "title #{n}" }
    sequence(:desc) { |n| "desc #{n}" }
    association :site_node
    user nil
  end
end
