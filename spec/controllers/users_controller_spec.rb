# frozen_string_literal: true

require "rails_helper"

describe UsersController, type: :controller do
  let(:user) { create :user, location: "Shanghai" }
  let(:deleted_user) { create :user, state: User.states[:deleted] }

  describe "Visit deleted user" do
    it "should 404 with deleted user" do
      get :show, params: { id: deleted_user.login }
      assert_equal 404, response.status
      get :topics, params: { id: deleted_user.login }
      assert_equal 404, response.status
    end
  end

  describe ":index" do
    it "should have an index action" do
      get :index
      assert_equal 200, response.status
    end
  end

  describe ":show" do
    it "should show user" do
      get :show, params: { id: user.login }
      assert_equal 200, response.status
    end

    it "should show team user" do
      team = create(:team)
      get :show, params: { id: team.login }
      assert_equal 200, response.status
    end
  end

  describe ":topics" do
    it "should show user topics" do
      get :topics, params: { id: user.login }
      assert_equal 200, response.status
    end

    it "should redirect to right spell login" do
      get :topics, params: { id: user.login.upcase }
      assert_equal 301, response.status
    end
  end

  describe ":replies" do
    it "should show user replies" do
      get :replies, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":favorites" do
    it "should show user liked stuffs" do
      get :favorites, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":block" do
    it "should work" do
      sign_in user
      get :block, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":unblock" do
    it "should work" do
      sign_in user
      get :unblock, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":blocked" do
    it "should work" do
      sign_in user
      get :blocked, params: { id: user.login }
      assert_equal 200, response.status
    end

    it "render 404 for wrong user" do
      user2 = create(:user)
      sign_in user
      get :blocked, params: { id: user2.login }
      assert_equal 404, response.status
    end
  end

  describe ":follow" do
    it "should work" do
      sign_in user
      get :follow, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":unfollow" do
    it "should work" do
      sign_in user
      get :unfollow, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":followers" do
    it "should work" do
      get :followers, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":following" do
    it "should work" do
      get :following, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ":city" do
    it "should render 404 if there is no user in that city" do
      get :city, params: { id: "Mars" }
      refute_equal 200, response.status
      assert_equal 404, response.status
    end

    it "should show user associated with that city" do
      get :city, params: { id: user.location }
      assert_equal 200, response.status
    end
  end

  describe ":calendar" do
    it "should work" do
      get :calendar, params: { id: user.login }
      assert_equal 200, response.status
    end
  end

  describe ".reward" do
    it "should not allow user close" do
      user.update_reward_fields(alipay: "XXXXXXX")
      get :reward, params: { id: user.login }, xhr: true
      assert_equal 200, response.status
      assert_includes response.body, "XXXXXXX"
    end
  end
end
