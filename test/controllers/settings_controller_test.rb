# frozen_string_literal: true

require "spec_helper"

describe SettingsController do
  let(:user) { create :user }

  describe "GET /setting" do
    it "should work" do
      sign_in user
      Setting.stubs(:sso_enabled?).returns(false)
      get setting_path
      assert_equal 200, response.status
      assert_equal true, response.body.include?("更新资料")
      assert_equal true, response.body.include?("登录密码")
      assert_equal true, response.body.include?(%(enctype="multipart/form-data"))

      Setting.stubs(:sso_enabled?).returns(true)
      get setting_path
      assert_equal false, response.body.include?("登录密码")
    end

    it "should new work with non user" do
      get setting_path
      assert_equal 302, response.status
    end
  end

  describe "GET /setting/reword" do
    it "should work" do
      sign_in user
      get reward_setting_path
      assert_equal 200, response.status
      assert_equal true, response.body.include?("关于打赏")
      assert_equal true, response.body.include?(%(enctype="multipart/form-data"))
    end
  end

  describe "GET /setting/account" do
    it "should work" do
      sign_in user
      get account_setting_path
      assert_equal 200, response.status
      assert_select ".authorizations", 0
      assert_select ".delete-account", text: /删除账号/
    end
  end

  describe "GET /setting/password" do
    it "should open password when not enable sso" do
      sign_in user
      Setting.stubs(:sso_enabled?).returns(false)
      get password_setting_path
      assert_equal 200, response.status
      assert_equal true, response.body.include?("修改密码")
    end

    it "should not open when sso enabled" do
      sign_in user
      Setting.stubs(:sso_enabled?).returns(true)
      get password_setting_path
      assert_equal 404, response.status
    end
  end

  describe "PUT /setting" do
    it "should work" do
      old_login = user.login
      sign_in user
      put setting_path, params: { user: { login: "new-#{user.login}", location: "BeiJing", profiles: { alipay: "alipay" } } }
      assert_redirected_to setting_path

      user.reload
      assert_equal old_login, user.login

      Setting.stubs(:allow_change_login?).returns(true)
      put setting_path, params: { user: { login: "new-#{user.login}" } }
      assert_redirected_to setting_path

      user.reload
      assert_equal "new-#{old_login}", user.login

      sign_in user
      put setting_path, params: { user: { location: "BeiJing", profiles: { alipay: "alipay" } } }
      assert_redirected_to setting_path

      put setting_path, params: { by: "profile", user: { location: "BeiJing", profiles: { alipay: "alipay" } } }
      assert_redirected_to profile_setting_path

      password_params = {
        current_password: user.password,
        password: "123",
        password_confirmation: "123123"
      }
      User.any_instance.stubs(:update_with_password).returns(true)
      put setting_path, params: { by: "password", user: password_params }
      assert_redirected_to "/account/sign_in"
    end

    it "should work for update email" do
      old_email = user.email
      sign_in user
      put setting_path, params: { user: { email: "new@email.com" } }
      assert_redirected_to setting_path
      user.reload
      assert_equal old_email, user.email

      # email was not locked
      user.update(email: "github+123@example.com")
      put setting_path, params: { user: { email: "new@email.com" } }
      assert_redirected_to setting_path
      user.reload
      assert_equal "new@email.com", user.email
    end
  end

  describe "DELETE /setting" do
    let(:user) { create :user }

    it "should redirect to root path after success" do
      sign_in user
      delete setting_path, params: { user: { current_password: user.password } }
      assert_redirected_to root_path
    end

    it "should render edit after failure" do
      sign_in user
      delete setting_path, params: { user: { current_password: "invalid password" } }
      assert_equal 200, response.status
    end
  end

  describe "DELETE /setting/auto_unbind" do
    it "should word" do
      sign_in user
      delete auth_unbind_setting_path("github"), params: { id: user.login }
      assert_redirected_to account_setting_path
    end

    it "have no provider" do
      user.bind_service("provider" => "github", "uid" => "ruby-china")
      user.bind_service("provider" => "twitter", "uid" => "ruby-china")
      sign_in user
      delete auth_unbind_setting_path("github"), params: { id: user.login }
      assert_redirected_to account_setting_path
      assert_nil user.authorizations.where(provider: "github").first
    end

    it "should not unbind with legacy oauth user" do
      user = create(:user, email: "foo@example.com")
      user.bind_service("provider" => "github", "uid" => "ruby-china")
      assert_equal true, user.legacy_omniauth_logined?

      sign_in user
      delete auth_unbind_setting_path("github"), params: { id: user.login }

      assert_redirected_to account_setting_path
      follow_redirect!
      assert_select ".alert", text: /账户三方账号登录且未设置 Email 和密码，不允许解绑/
    end
  end
end
