# frozen_string_literal: true

require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "normal user sign up" do
    get new_user_registration_path
    assert_equal 200, response.status
    assert_select ".btn-primary", value: "Sign Up"

    assert_select "input[name='_rucaptcha']"
    assert_select ".rucaptcha-image"

    assert_no_match "Complete your account information", response.body
    assert_select %(input[name="user[omniauth_provider]"]), 0
    assert_select %(input[name="user[omniauth_uid]"]), 0

    user = create(:user)
    sign_in user

    get new_user_registration_path
    assert_redirected_to root_path

    sign_out user

    user_params = {
      login: "monster",
      email: "monster@gmail.com",
      name: "Monster",
      email_public: "1",
      password: "123456",
      password_confimation: "123456",
    }

    # Check captcha
    post user_registration_path, params: { user: user_params }
    assert_equal 200, response.status
    assert_match "The captcha code is incorrect", response.body

    ActionController::Base.any_instance.stubs(:verify_complex_captcha?).returns(true)
    post user_registration_path, params: { user: user_params }
    assert_sign_up_success

    user = User.last
    assert_equal user_params[:login], user.login
    assert_equal user_params[:email], user.email
    assert_equal user_params[:name], user.name
    assert_equal true, user.email_public?
    assert_equal true, user.valid_password?(user_params[:password])

    post user_session_path, params: { user: { login: user_params[:email], password: user_params[:password] } }
    assert_redirected_to root_path
    assert_signed_in
  end

  it "should not has captcha" do
    Setting.stubs(:captcha_enable?).returns(false)
    get new_user_registration_path
    assert_equal 200, response.status
    assert_select ".rucaptcha-image", 0
  end


  test "Signup with captcha disabled" do
    Setting.stub(:use_recaptcha, "false") do
      get new_user_registration_path
      assert_equal 200, response.status
      assert_select ".btn-primary", value: "Sign Up"

      assert_select "input[name='_rucaptcha']", 0
      assert_select ".rucaptcha-image", 0

      user_params = {
        login: "monster",
        name: "Monster",
        email: "monster@gmail.com",
        password: "123456",
        password_confimation: "123456",
      }

      # Check captcha
      post user_registration_path, params: { user: user_params }
      assert_sign_up_success

      user = User.last
      assert_equal user_params[:login], user.login
      assert_equal user_params[:email], user.email
    end
  end

  test "Sign up with Omniauth" do
    ActionController::Base.any_instance.stubs(:verify_complex_captcha?).returns(true)
    OmniAuth.config.add_mock(:github, uid: "github-123", info: { "name" => "Fake Name", "email" => "fake@gmail.com" })

    get "/account/auth/github/callback"
    assert_redirected_to new_user_registration_path

    omniauth = session[:omniauth]
    assert_not_nil omniauth
    assert_equal "github", omniauth["provider"]
    assert_equal "github-123", omniauth["uid"]
    omniauth_info = omniauth["info"]
    assert_not_nil omniauth_info
    assert_equal "Fake Name", omniauth_info["name"]
    assert_equal "fake", omniauth_info["login"]
    assert_equal "fake@gmail.com", omniauth_info["email"]

    get new_user_registration_path
    assert_equal 200, response.status

    assert_select %(input[name="user[omniauth_provider]"]) do
      assert_select %([value=?]), "github"
    end
    assert_select %(input[name="user[omniauth_uid]"]) do
      assert_select %([value=?]), "github-123"
    end
    assert_select %(input[name="user[name]"]) do
      assert_select %([value=?]), "Fake Name"
    end
    assert_select %(input[name="user[login]"]) do
      assert_select %([value=?]), "fake"
    end
    assert_select %(input[name="user[email]"]) do
      assert_select %([value=?]), "fake@gmail.com"
    end

    # post with incorrect validation, to make sure post params first priority
    user_params = {
      login: "fake-foo-foo",
      name: "Fake Foo Foo",
      email: "bad email",
      password: "123456",
      password_confimation: "123456",
    }

    post user_registration_path, params: { user: user_params }
    assert_equal 200, response.status
    assert_select ".alert", text: /Email/

    assert_not_nil session[:omniauth]

    assert_select %(input[name="user[omniauth_provider]"]) do
      assert_select %([value=?]), "github"
    end
    assert_select %(input[name="user[omniauth_uid]"]) do
      assert_select %([value=?]), "github-123"
    end
    assert_select %(input[name="user[name]"]) do
      assert_select %([value=?]), user_params[:name]
    end
    assert_select %(input[name="user[login]"]) do
      assert_select %([value=?]), user_params[:login]
    end
    assert_select %(input[name="user[name]"]) do
      assert_select %([value=?]), user_params[:name]
    end
    assert_select %(input[name="user[email]"]) do
      assert_select %([value=?]), user_params[:email]
    end

    # post with correct
    user_params = {
      omniauth_provider: "github",
      omniauth_uid: "github-123",
      login: "fake-foo-foo",
      name: "Fake Foo Foo",
      email: "fake@gmail.com",
      password: "123456",
      password_confimation: "123456",
    }
    post user_registration_path, params: { user: user_params }
    assert_sign_up_success

    assert_nil session[:omniauth]

    # check authorizations bind
    user = User.find_by_login(user_params[:login])
    assert_not_nil user
    assert_equal 1, user.authorizations.count
    auth = user.authorizations.first
    assert_equal "github", auth.provider
    assert_equal "github-123", auth.uid
  end

  def assert_sign_up_success
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".alert-success", text: /Welcome! You have signed up successfully/
  end
end
