# frozen_string_literal: true

require "spec_helper"

describe AccountController do
  describe "GET /account/sign_up" do
    it "should render new template" do
      get "/account/sign_up"
      assert_equal 200, response.status
    end

    it "should redirect to sso login" do
      Setting.stubs(:sso_enabled?).returns(true)
      get "/account/sign_up"
      assert_equal 302, response.status
      assert_includes response.location, "/auth/sso"
    end
  end

  describe "POST /account" do
    let(:user) { create :user }

    it "should work" do
      ActionController::Base.any_instance.stubs(:verify_complex_captcha).returns(true)
      post "/account", params: { format: :js, user: { login: "newlogin", email: "newlogin@email.com", password: "password" } }
      assert_equal 200, response.status
    end
  end

  describe "GET /account/edit" do
    let(:user) { create :user }

    it "should work" do
      sign_in user
      get "/account/edit"
      assert_equal 302, response.status
      assert_includes response.location, "/setting"
    end
  end
end
