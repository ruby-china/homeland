FactoryGirl.define do
  factory :option, class: VoteOption do
    sequence(:oid)
    sequence(:description) { |n| "option #{n}" }
  end
end
