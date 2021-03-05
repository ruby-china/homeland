# frozen_string_literal: true

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, login: "huacnlee", email: "huacnlee@gmail.com", password: "123456", password_confirmation: "123456")
  end

  test "GET /account/sign_in" do
    get new_user_session_path
    assert_equal 200, response.status
    assert_select "title", text: /Sign In/

    assert_select ".omniauth-github"
    assert_select ".omniauth-twitter"
    assert_select ".omniauth-wechat"

    sign_in @user
    get new_user_session_path
    assert_redirected_to root_path
  end

  test "POST /account/sign_in with login" do
    post user_session_path, params: {user: {login: "huacnlee"}}
    assert_equal 200, response.status
    assert_select ".alert", text: /Invalid Username or password/

    post user_session_path, params: {user: {login: "huacnlee", password: "1234"}}
    assert_equal 200, response.status
    assert_select ".alert", text: /Invalid Username or password/

    # Do sign in
    post user_session_path, params: {user: {login: "huacnlee", password: "123456"}}
    assert_signed_in
  end

  test "POST /account/sign_in with login insensitive" do
    # Do sign in
    post user_session_path, params: {user: {login: "HUacnlee", password: "123456"}}
    assert_signed_in
  end

  test "POST /account/sign_in with email" do
    post user_session_path, params: {user: {login: "huacnlee@gmail.com"}}
    assert_equal 200, response.status
    assert_select ".alert", text: /Invalid Username or password/

    post user_session_path, params: {user: {login: "huacnlee@gmail.com", password: "1234"}}
    assert_equal 200, response.status
    assert_select ".alert", text: /Invalid Username or password/

    # Do sign in
    post user_session_path, params: {user: {login: "huacnlee@gmail.com", password: "123456"}}
    assert_signed_in
  end

  test "POST /account/sign_in with email insensitive" do
    # Do sign in
    post user_session_path, params: {user: {login: "HUacnlee@Gmail.com", password: "123456"}}
    assert_signed_in
  end

  test "POST /account/sign_in with omniauth" do
    OmniAuth.config.add_mock(:github, uid: "github-123")

    get "/account/auth/github/callback"
    assert_redirected_to new_user_registration_path

    # go to sign in page to bind user
    post user_session_path, params: {user: {login: "huacnlee", password: "123456"}}
    assert_signed_in

    auth = @user.authorizations.where(provider: "github").first
    assert_not_nil auth
    assert_equal auth.provider, "github"
    assert_equal auth.uid, "github-123"

    # sign out, and sign in with other user
    delete destroy_user_session_path

    user1 = create(:user, password: "123456", password_confirmation: "123456")
    OmniAuth.config.add_mock(:github, uid: "github-234")
    get "/account/auth/github/callback"
    assert_redirected_to new_user_registration_path
    post user_session_path, params: {user: {login: user1.email, password: "123456"}}
    assert_signed_in
    assert_select ".alert-success", text: /Sign in successfully with bind GitHub/

    auth = user1.authorizations.where(provider: "github").first
    assert_not_nil auth
    assert_equal "github-234", auth.uid
    assert_equal user1.id, auth.user_id

    # sign out, and sign in with other user
    delete destroy_user_session_path

    OmniAuth.config.add_mock(:wechat, uid: "wechat-123")
    get "/account/auth/wechat/callback"
    assert_redirected_to new_user_registration_path
    post user_session_path, params: {user: {login: user1.email, password: "123456"}}
    assert_signed_in
    assert_select ".alert-success", text: /Sign in successfully with bind 微信/

    auth = user1.authorizations.where(provider: "wechat").first
    assert_not_nil auth
    assert_equal "wechat-123", auth.uid
    assert_equal user1.id, auth.user_id
  end

  test "POST /account/sign_in with omniauth when bind exist" do
    OmniAuth.config.add_mock(:github, uid: "github-123")

    create(:authorization, provider: "github", uid: "github-123", user: @user)

    get "/account/auth/github/callback"
    assert_signed_in

    OmniAuth.config.add_mock(:github, uid: "github-234")
    get "/account/auth/github/callback"
    assert_redirected_to new_user_registration_path

    # make sure sign in will bind
    post user_session_path, params: {user: {login: "huacnlee", password: "123456"}}
    assert_signed_in

    auth = @user.authorizations.where(provider: "github").first
    assert_not_nil auth
    assert_equal auth.provider, "github"
    assert_equal auth.uid, "github-123"

    assert_equal 1, Authorization.count
  end

  test "GET /account/sign_in with sso enable" do
    Setting.stubs(:sso_enabled?).returns(true)
    get "/account/sign_in"
    assert_equal 302, response.status
    assert_includes response.location, "/auth/sso"
  end

  test "GET /account/sign_in should store referrer if it's from self site" do
    create(:topic)
    # visit topic to store session["return_to"]
    get new_topic_path
    assert_equal new_topic_url, session["return_to"]

    old_return_to = new_topic_url

    get "/account/sign_in"
    assert_equal 200, response.status
    assert_equal old_return_to, session["return_to"]
  end

  test "POST /account/sign_in should render json" do
    user = create(:user)
    post "/account/sign_in", params: {format: :json, user: {login: user.login, password: user.password}}
    assert_equal 201, response.status
    assert_equal user.login, response.parsed_body["login"]
    assert_equal user.email, response.parsed_body["email"]
  end
end
