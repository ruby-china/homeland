require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  test "should clear user mention notification when show topic" do
    notification = Factory :notification_mention
    sign_in notification.user
    assert_difference "notification.user.notifications.unread.count", -1 do
      get :show, :id => notification.reply.topic
    end
  end
end
