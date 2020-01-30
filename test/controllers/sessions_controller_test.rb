# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET /account/sign_in" do
    get "/account/sign_in"
    assert_equal 200, response.status
  end

  test "GET /account/sign_in with sso enable" do
    Setting.stubs(:sso_enabled?).returns(true)
    get "/account/sign_in"
    assert_equal 302, response.status
    assert_includes response.location, "/auth/sso"
  end

  test "GET /account/sign_in should store referrer if it's from self site" do
    old_return_to = "/account/edit?id=123"
    topic = create(:topic)
    # visit topic to store session["return_to"]
    get new_topic_path
    assert_equal new_topic_url, session["return_to"]

    old_return_to = new_topic_url

    get "/account/sign_in"
    assert_equal 200, response.status
    assert_equal old_return_to, session["return_to"]
  end

  test "POST /account/sign_in" do
    user = create(:user)
    post "/account/sign_in", params: { user: { login: user.login, password: user.password } }
    assert_redirected_to root_path
  end

  test "POST /account/sign_in should render json" do
    user = create(:user)
    post "/account/sign_in", params: { format: :json, user: { login: user.login, password: user.password } }
    assert_equal 201, response.status
    assert_equal user.login, response.parsed_body["login"]
    assert_equal user.email, response.parsed_body["email"]
  end
end
