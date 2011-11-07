require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  test "should get index" do
    user = Factory :user
    sign_in user
    3.times { Factory :notification_mention, :user => user }
    get :index
    assert_response :success, @response.body
  end

  test "should destroy notification" do
    user = Factory :user
    sign_in user
    notification = Factory :notification_mention, :user => user

    assert_difference "user.notifications.count", -1 do
      delete :destroy, :id => notification
    end
  end

  test "should mark all as read" do
    user = Factory :user
    sign_in user
    3.times{ Factory :notification_mention, :user => user }

    put :mark_all_as_read
    assert_equal 0, user.notifications.unread.count
  end
end
