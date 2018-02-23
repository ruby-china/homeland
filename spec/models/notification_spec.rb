# frozen_string_literal: true

require "rails_helper"

describe Notification, type: :model do
  let(:n) { create(:notification_topic_reply) }

  describe ".realtime_push_to_client" do
    it "should work" do
      hash = {}
      hash[:count] = n.user.notifications.unread.count
      args = ["notifications_count/#{n.user_id}", hash]
      expect(ActionCable.server).to receive(:broadcast).with(*args).once
      n.realtime_push_to_client
    end
  end
end
