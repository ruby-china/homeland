# frozen_string_literal: true

require "test_helper"

class User::DeviseableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class Monkey < ApplicationRecord
    include User::Deviseable
  end

  setup do
    @data = {"email" => "email@example.com", "nickname" => "_why", "name" => "why"}
    @uid = "42"
  end

  attr_accessor :data, :uid

  test "new_from_provider_data should create a new user" do
    assert_kind_of User, Monkey.new_from_provider_data(nil, nil, data)
  end

  test "new_from_provider_data should with twitter" do
    result = Monkey.new_from_provider_data("twitter", uid, data)
    assert_equal "email@example.com", result.email
  end

  test "new_from_provider_data with github" do
    result = Monkey.new_from_provider_data("github", uid, data)
    assert_equal "email@example.com", result.email
  end

  test "new_from_provider_data should escape illegal characters in nicknames properly" do
    data["nickname"] = "I <3 Rails"
    assert_equal "I__3_Rails", Monkey.new_from_provider_data(nil, nil, data).login
  end

  test "new_from_provider_data should generate random login if login is empty" do
    data["nickname"] = ""
    time = Time.now
    Time.stub(:now, time) do
      assert_equal "u#{time.to_i}", Monkey.new_from_provider_data(nil, nil, data).login
    end
  end

  test "new_from_provider_data should generate random login if login is duplicated" do
    Monkey.new_from_provider_data("github", nil, data).save # create a new user first
    time = Time.now
    Time.stub(:now, time) do
      assert_equal "#{data["nickname"]}-github", Monkey.new_from_provider_data("github", nil, data).login
    end
  end

  test "new_from_provider_data should generate some random password" do
    assert_equal true, Monkey.new_from_provider_data(nil, nil, data).password.present?
  end

  test "new_from_provider_data should set user location" do
    data["location"] = "Shanghai"
    assert_equal "Shanghai", Monkey.new_from_provider_data(nil, nil, data).location
  end

  test "new_from_provider_data should set user tagline" do
    description = data["description"] = "A newbie Ruby developer"
    assert_equal description, Monkey.new_from_provider_data(nil, nil, data).tagline
  end

  test "async mailer" do
    user = create(:user)

    assert_performed_jobs 1 do
      user.send(:send_devise_notification, :reset_password_instructions, "foobar")
    end
  end
end
