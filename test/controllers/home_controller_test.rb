# frozen_string_literal: true

require "spec_helper"

describe HomeController, type: :controller do
  describe "GET /" do
    let(:user) { create :user }

    it "should show register link if user not signed in" do
      get root_path
      assert_equal 200, response.status
      assert_equal true, response.body.include?("注册")
    end

    it "should not show register link if sso enabled" do
      Setting.stubs(:sso_enabled?).returns(true)
      get root_path
      assert_equal 200, response.status
      assert_equal false, response.body.include?("注册")
    end

    it "should have hot topic lists if user is signed in" do
      sign_in user

      get root_path
      assert_match /社区精华帖/, response.body
    end
  end

  describe "GET /uploads" do
    it "render 404 for non-existed file" do
      get "/uploads/what", params: { format: "jpg" }
      assert_equal 404, response.status
    end
  end

  describe "GET /api" do
    it "should redirect to /api-doc" do
      get "/api"
      assert_redirected_to "/api-doc/"
    end
  end
end
