# frozen_string_literal: true

require "spec_helper"

describe Auth::SSOController do
  let(:sso_secret) { "foo(*&@!12q36)" }

  describe "GET /auth/sso/show" do
    before do
      @sso_url = "http://somesite.com/homeland-sso"

      Setting.stubs(:sso).returns(
        "enable" => true,
        "url" => @sso_url,
        "secret" => sso_secret
      )
      Setting.stubs(:sso_enabled?).returns(true)
    end

    it "should work" do
      get auth_sso_path, params: {return_path: "/topics/123"}
      assert_equal 302, response.status

      # javascript code will handle redirection of user to return_sso_url
      assert_match(/^http:\/\/somesite.com\/homeland-sso\?sso=.*&sig=.*/, response.location)
    end

    it "should work with destination_url" do
      get auth_sso_path, headers: {Cookie: "destination_url=/topics/123"}
      assert_equal 302, response.status

      # javascript code will handle redirection of user to return_sso_url
      assert_match(/^http:\/\/somesite.com\/homeland-sso\?sso=.*&sig=.*/, response.location)
    end
  end

  describe "GET /auth/sso/login" do
    let(:mock_ip) { "11.22.33.44" }
    before do
      @sso_url = "http://somesite.com/homeland-sso"

      @headers = {
        HTTP_CLIENT_IP: mock_ip,
        Host: Setting.domain
      }

      Setting.stubs(:sso).returns(
        "enable" => true,
        "url" => @sso_url,
        "secret" => sso_secret
      )
      Setting.stubs(:sso_enabled?).returns(true)
    end

    def get_sso(return_path)
      nonce = SecureRandom.hex
      dso = Homeland::SSO.new
      dso.nonce = nonce
      dso.register_nonce(return_path)

      sso = SingleSignOn.new
      sso.nonce = nonce
      sso.sso_secret = sso_secret
      sso
    end

    it "can take over an account" do
      user_template = build(:user)
      sso = get_sso("/topics/123")
      sso.email = user_template.email
      sso.external_id = "abc123"
      sso.name = "Test SSO User"
      sso.username = "test-sso-user"
      sso.bio = "This is a bio text"
      sso.avatar_url = "http://foobar.com/avatar/1.jpg"
      sso.admin = false

      get login_auth_sso_path, params: Rack::Utils.parse_query(sso.payload), headers: @headers
      assert_redirected_to "/topics/123"

      user = User.find_by_email(sso.email)
      assert_equal false, user.new_record?
      assert_equal false, user.admin?
      assert_equal sso.username, user.login
      assert_equal sso.name, user.name
      assert_equal sso.bio, user.bio
      refute_equal nil, user.sso
      assert_equal sso.external_id, user.sso.uid
      assert_equal sso.username, user.sso.username
      assert_equal sso.name, user.sso.name
      assert_equal sso.email, user.sso.email
      assert_equal sso.avatar_url, user.sso.avatar_url
      assert_equal mock_ip, user.current_sign_in_ip
      refute_equal nil, user.current_sign_in_at
    end

    it "can sign a exist user" do
      user = create(:user, name: nil, bio: nil)
      user.create_sso(uid: "abc1237161", last_payload: "")

      sso = get_sso("/")
      sso.email = user.email
      sso.external_id = user.sso.uid
      sso.name = "Test SSO User"
      sso.username = "test-sso-user"
      sso.bio = "This is a bio text"
      sso.avatar_url = "http://foobar.com/avatar/1.jpg"

      assert_no_changes -> { User.count } do
        get login_auth_sso_path, params: Rack::Utils.parse_query(sso.payload), headers: @headers
      end
      assert_redirected_to "/"

      user1 = User.find_by_id(user.id)
      assert_equal sso.name, user1.name
      assert_equal user.login, user1.login
      assert_equal sso.bio, user1.bio
    end

    it "can take an admin account" do
      user_template = build(:user)
      sso = get_sso("/hello/world")
      sso.email = user_template.email
      sso.external_id = "abc123"
      sso.name = "Test SSO User"
      sso.username = user_template.login
      sso.admin = true

      get login_auth_sso_path, params: Rack::Utils.parse_query(sso.payload), headers: @headers
      assert_redirected_to "/hello/world"

      user = User.find_by_email(sso.email)
      assert_equal "admin", user.state
    end

    it "show error when create failure" do
      Homeland::SSO.any_instance.stubs(:find_or_create_user).raises(StandardError)

      user_template = build(:user)
      sso = get_sso("/topics/123")
      sso.email = user_template.email
      sso.external_id = "abc123"
      sso.name = "Test SSO User"
      sso.username = "test-sso-user"
      sso.bio = "This is a bio text"
      sso.avatar_url = "http://foobar.com/avatar/1.jpg"
      sso.admin = false

      assert_output(/nonce: #{sso.nonce}/) do
        get login_auth_sso_path, params: Rack::Utils.parse_query(sso.payload), headers: @headers
      end
      assert_equal 500, response.status
    end

    it "show error when timeout expried" do
      user_template = build(:user)
      sso = get_sso("/topics/123")
      sso.email = user_template.email
      sso.external_id = "abc123"
      sso.name = "Test SSO User"
      sso.username = "test-sso-user"
      sso.bio = "This is a bio text"
      sso.avatar_url = "http://foobar.com/avatar/1.jpg"
      sso.admin = false

      Redis.current.del("SSO_NONCE_#{sso.nonce}")
      get login_auth_sso_path, params: Rack::Utils.parse_query(sso.payload), headers: @headers
      assert_equal 419, response.status
    end
  end

  describe "GET /auth/sso/provider" do
    let(:user) { create(:user) }

    before do
      Setting.stubs(:sso).returns(
        "secret" => sso_secret
      )
      Setting.stubs(:sso_provider_enabled?).returns(true)

      @sso = SingleSignOn.new
      @sso.nonce = "mynonce"
      @sso.sso_secret = sso_secret
      @sso.return_sso_url = "http://foobar.com/sso/callback"
    end

    it "should work" do
      admin = create(:admin)
      sign_in admin

      get provider_auth_sso_path, params: Rack::Utils.parse_query(@sso.payload)
      assert_equal 302, response.status

      location = response.location
      # javascript code will handle redirection of user to return_sso_url
      assert_match(/^http:\/\/foobar.com\/sso\/callback/, location)

      payload = location.split("?")[1]

      sso2 = SingleSignOn.parse(payload, @sso.sso_secret)
      assert_equal admin.email, sso2.email
      assert_equal admin.name, sso2.name
      assert_equal admin.login, sso2.username
      assert_equal admin.id.to_s, sso2.external_id
      assert_equal true, sso2.admin
    end

    it "should work with sign in" do
      get provider_auth_sso_path, params: Rack::Utils.parse_query(@sso.payload)
      assert_redirected_to "/account/sign_in"
      assert_match(/\/auth\/sso\/provider/, session[:return_to])
      assert_equal request.url, session[:return_to]
    end
  end
end
