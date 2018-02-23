# frozen_string_literal: true

FactoryBot.define do
  factory :team_user do
    association :team
    association :user
    role :member
    status :accepted
  end

  factory :team_owner, parent: :team_user do
    role :owner
  end

  factory :team_member, parent: :team_user do
    role :member
  end
end
