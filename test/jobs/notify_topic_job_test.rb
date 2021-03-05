# frozen_string_literal: true

require "test_helper"

class NotifyTopicJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  attr_accessor :topic, :user

  setup do
    @topic = create(:topic)
    @user = create(:user)
  end

  test ".perform" do
    followers = create_list(:user, 3)
    followers.each do |f|
      f.follow_user(user)
    end

    perform_enqueued_jobs do
      create(:topic, user: user)
    end

    followers.each do |f|
      assert_equal 1, f.notifications.unread.where(notify_type: "topic").count
    end
  end
end
