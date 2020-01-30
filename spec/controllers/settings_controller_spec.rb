# frozen_string_literal: true

require "rails_helper"

describe SettingsController, type: :controller do
  let(:user) { create :user }

  describe ":show" do
    it "should work" do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(false)
      get :show
      assert_equal 200, response.status
      assert_equal true, response.body.include?("更新资料")
      assert_equal true, response.body.include?("登录密码")
      assert_equal true, response.body.include?(%(enctype="multipart/form-data"))

      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :show
      assert_equal false, response.body.include?("登录密码")
    end

    it "should new work with non user" do
      get :show
      assert_equal 302, response.status
    end
  end

  describe ":reword" do
    it "should work" do
      sign_in user
      get :reward
      assert_equal 200, response.status
      assert_equal true, response.body.include?("关于打赏")
      assert_equal true, response.body.include?(%(enctype="multipart/form-data"))
    end
  end

  describe ":account" do
    it "should work" do
      sign_in user
      get :account
      assert_equal 200, response.status
      assert_equal true, response.body.include?("绑定其他帐号用于登录")
      assert_equal true, response.body.include?("删除账号")
    end
  end

  describe ":password" do
    it "should open password when not enable sso" do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(false)
      get :password
      assert_equal 200, response.status
      assert_equal true, response.body.include?("修改密码")
    end

    it "should not open when sso enabled" do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :password
      assert_equal 404, response.status
    end
  end

  describe ":update" do
    it "should work" do
      old_login = user.login
      sign_in user
      put :update, params: { user: { login: "new-#{user.login}", location: "BeiJing", profiles: { alipay: "alipay" } } }
      assert_redirected_to setting_path

      user.reload
      assert_equal old_login, user.login

      allow(Setting).to receive(:allow_change_login?).and_return(true)
      put :update, params: { user: { login: "new-#{user.login}" } }
      assert_redirected_to setting_path

      user.reload
      assert_equal "new-#{old_login}", user.login

      sign_in user
      put :update, params: { user: { location: "BeiJing", profiles: { alipay: "alipay" } } }
      assert_redirected_to setting_path

      put :update, params: { by: "profile", user: { location: "BeiJing", profiles: { alipay: "alipay" } } }
      assert_redirected_to profile_setting_path

      password_params = {
        current_password: user.password,
        password: "123",
        password_confirmation: "123123"
      }
      allow_any_instance_of(User).to receive(:update_with_password).and_return(true)
      put :update, params: { by: "password", user: password_params }
      assert_redirected_to "/account/sign_in"
    end
  end

  describe ":destroy" do
    let(:user) { create :user }
    before { request.env["devise.mapping"] = Devise.mappings[:user] }
    it "should redirect to root path after success" do
      sign_in user
      delete :destroy, params: { user: { current_password: user.password } }
      assert_redirected_to root_path
    end

    it "should render edit after failure" do
      sign_in user
      delete :destroy, params: { user: { current_password: "invalid password" } }
      assert_equal 200, response.status
    end
  end

  describe ":auto_unbind" do
    it "should word" do
      sign_in user
      delete :auth_unbind, params: { id: user.login, provider: "github" }
      assert_redirected_to account_setting_path
    end

    it "have no provider" do
      user.bind_service("provider" => "github", "uid" => "ruby-china")
      user.bind_service("provider" => "twitter", "uid" => "ruby-china")
      sign_in user
      delete :auth_unbind, params: { id: user.login, provider: "github" }
      assert_redirected_to account_setting_path
    end
  end
end
