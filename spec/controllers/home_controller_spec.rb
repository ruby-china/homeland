# frozen_string_literal: true

require "rails_helper"

describe HomeController, type: :controller do
  describe ":index" do
    let(:user) { create :user }
    it "should show register link if user not signed in" do
      get :index
      assert_equal 200, response.status
      assert_equal true, response.body.include?("注册")
    end

    it "should not show register link if sso enabled" do
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :index
      assert_equal 200, response.status
      assert_equal false, response.body.include?("注册")
    end

    it "should have hot topic lists if user is signed in" do
      sign_in user

      get :index
      assert_match /社区精华帖/, response.body
    end
  end

  describe ":uploads" do
    it "render 404 for non-existed file" do
      get :uploads, params: { path: "what", format: "jpg" }
      assert_equal 404, response.status
    end
  end

  describe ":api" do
    it "should redirect to /api-doc" do
      get :api
      assert_redirected_to "/api-doc/"
    end
  end
end
