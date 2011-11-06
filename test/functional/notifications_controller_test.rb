require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  test "should get index" do
    user = Factory :user
    sign_in user
    3.times { Factory :notification_mention, :user => user }
    get :index
    assert_response :success, @response.body
  end
end
