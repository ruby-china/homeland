# frozen_string_literal: true

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test ".realtime_push_to_client" do
    note = create(:notification_topic_reply)

    hash = {}
    hash[:count] = note.user.notifications.unread.count
    args = ["notifications_count/#{note.user_id}", hash]
    ActionCable.server.expects(:broadcast).with(*args).once
    note.realtime_push_to_client
  end
end
