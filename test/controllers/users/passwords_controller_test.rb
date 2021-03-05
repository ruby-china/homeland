# frozen_string_literal: true

require "spec_helper"

describe Users::PasswordsController, type: :controller do
  describe "GET /account/password/new" do
    it "should render new tempalte" do
      get "/account/password/new"
      assert_equal 200, response.status
      assert_select ".rucaptcha-image", 1
    end

    it "should not has captcha" do
      Setting.stubs(:captcha_enable?).returns(false)
      get "/account/password/new"
      assert_equal 200, response.status
      assert_select ".rucaptcha-image", 0
    end

    it "should redirect to sso login" do
      Setting.stubs(:sso_enabled?).returns(true)
      get "/account/password/new"
      assert_equal 302, response.status
      assert_includes response.location, "/auth/sso"
    end
  end

  describe "POST /account/password" do
    let(:user) { create(:user) }

    it "should work" do
      post "/account/password", params: {user: {email: user.email}}
      assert_equal 200, response.status
    end

    it "should redirect to sign in path after success" do
      ActionController::Base.any_instance.stubs(:verify_complex_captcha?).returns(true)
      post "/account/password", params: {user: {email: user.email}}
      assert_redirected_to "/account/sign_in"
    end

    it "should work with captcha disabled" do
      Setting.stubs(:captcha_enable?).returns(false)
      post "/account/password", params: {user: {email: user.email}}
      assert_redirected_to "/account/sign_in"
    end
  end
end
