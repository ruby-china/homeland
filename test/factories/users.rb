# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "name#{n}" }
    sequence(:login) { |n| "login#{n}" }
    sequence(:email) { |n| "email#{n}@gethomeland.com" }
    password { "password" }
    password_confirmation { "password" }
    location { "China" }
    created_at { 100.days.ago }
  end

  factory :avatar_user, parent: :user do
    avatar { File.open(Rails.root.join("test/fixtures/files/test.png")) }
  end

  factory :admin, parent: :user do
    state { "admin" }
  end

  factory :vip, parent: :user do
    state { "vip" }
  end

  factory :hr, parent: :user do
    state { "hr" }
  end

  factory :newbie, parent: :user do
    created_at { 1.hours.ago }
  end

  factory :blocked_user, parent: :user do
    created_at { 30.days.ago }
    state { "blocked" }
  end

  factory :deleted_user, parent: :user do
    created_at { 100.days.ago }
    state { "deleted" }
  end
end
