FactoryGirl.define do
  factory :page do
    sequence(:slug){|n| "slug#{n}" }
    sequence(:title){|n| "title#{n}" }
    sequence(:body){|n| "body#{n}" }
    sequence(:body_html){|n| "body_html#{n}" }
  end
end
