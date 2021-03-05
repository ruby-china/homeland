# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "GET / without signed in" do
    get root_path
    assert_equal 200, response.status
    assert_select ".navbar .nav-link", text: "Sign Up"
  end

  test "GET / with SSO enabled" do
    Setting.stubs(:sso_enabled?).returns(true)
    get root_path
    assert_equal 200, response.status
    assert_equal false, response.body.include?("Sign Up")
  end

  test "GET / with signed in" do
    user = create(:user)
    sign_in user
    get root_path
    assert_select ".notification-count"
  end

  test "GET /uploads/:id with not exist file" do
    get "/uploads/what", params: {format: "jpg"}
    assert_equal 404, response.status
  end

  test "GET /status" do
    get "/status"
    assert_equal 200, response.status
  end

  test "GET /status with timezone" do
    # Bad timezone
    Setting.stub(:timezone, "foo") do
      get "/status"
      assert_equal 200, response.status
    end
  end
end
