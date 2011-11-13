require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  test "should clear user mention notification when show topic" do
    notification = Factory :notification_mention
    sign_in notification.user
    assert_difference "notification.user.notifications.unread.count", -1 do
      get :show, :id => notification.reply.topic
    end
  end

  test "should read topic after user reply topic" do
    user = Factory :user
    topic = Factory :topic
    Factory :reply, :topic => topic
    assert_equal 1, topic.user_readed?(user.id)
    sign_in user
    post :reply, :id => topic, :reply => {:body => 'content'}, :format => :js
    assert_equal 0, topic.user_readed?(user.id)
  end
end
