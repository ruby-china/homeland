require 'spec_helper'

describe TopicsController do
  describe "#show" do
    it "should clear user mention notification when show topic" do
      notification = Factory :notification_mention
      sign_in notification.user
      lambda do
        get :show, :id => notification.reply.topic
      end.should change(notification.user.notifications.unread, :count)
    end
  end
end
