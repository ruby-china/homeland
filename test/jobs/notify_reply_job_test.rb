# frozen_string_literal: true

require "test_helper"

class NotifyReplyJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  attr_accessor :user
  setup do
    @user = create(:user)
  end

  test ".perform" do
    followers = create_list(:user, 3)
    replyer = create :user

    followers.each do |f|
      f.follow_user(replyer)
    end

    topic = create :topic, user: user
    reply = nil
    perform_enqueued_jobs do
      reply = create :reply, topic: topic, user: replyer
      create :reply, action: "ban", topic: topic, user: replyer
    end

    followers.each do |f|
      assert_equal 1, f.notifications.unread.where(notify_type: "topic_reply").count
    end

    assert_changes -> { user.notifications.unread.where(notify_type: "topic_reply").count }, 1 do
      NotifyReplyJob.perform_now(reply.id)
    end
  end
end
