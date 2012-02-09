FactoryGirl.define do
  factory :post do
    sequence(:title) { |n| "title #{n}" }
    body 'post body'
    tag_list "some tags"
  end
end
