# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site do
    name "MyString"
    url "MyString"
    desc "MyString"
    site_node nil
    user nil
  end
end
