# frozen_string_literal: true

require "spec_helper"

describe UsersController do
  let(:user) { create :user, location: "Shanghai" }
  let(:deleted_user) { create :user, state: User.states[:deleted] }

  it "GET /users" do
    get users_path
    assert_equal 200, response.status
  end

  describe "GET /users/:id" do
    it "should show user" do
      get user_path(user)
      assert_equal 200, response.status

      get user_path(user.login.upcase)
      assert_equal 301, response.status
      assert_redirected_to user_path(user.login)
    end

    it "should show team user" do
      team = create(:team)
      get user_path(team)
      assert_equal 200, response.status
    end

    it "should 404 with deleted user" do
      get user_path(deleted_user)
      assert_equal 404, response.status
      get topics_user_path(deleted_user)
      assert_equal 404, response.status
    end
  end

  describe "GET /users/:id/topics" do
    it "should show user topics" do
      get topics_user_path(user)
      assert_equal 200, response.status
    end

    it "should redirect to right spell login" do
      get topics_user_path(user.login.upcase)
      assert_equal 301, response.status
      assert_redirected_to user_path(user.login)
    end
  end

  it "GET /users/:id/feed" do
    get feed_user_path(user)
    assert_equal 200, response.status
  end

  it "GET /users/:id/replies" do
    get replies_user_path(user)
    assert_equal 200, response.status
  end

  it "GET /users/:id/favorites" do
    get favorites_user_path(user)
    assert_equal 200, response.status
  end

  it "POST /users/:id/block" do
    sign_in user
    other_user = create(:user)
    assert_equal false, user.block_user?(other_user)

    post block_user_path(other_user)
    assert_equal 200, response.status
    assert_equal true, user.block_user?(other_user)
  end

  it "GET /users/:id/unblock" do
    sign_in user
    other_user = create(:user)
    user.block_user(other_user)
    assert_equal true, user.block_user?(other_user)

    post unblock_user_path(other_user)
    assert_equal 200, response.status
    assert_equal false, user.block_user?(other_user)
  end

  describe "GET /users/:id/blocked" do
    it "should work for self" do
      sign_in user
      get blocked_user_path(user)
      assert_equal 200, response.status
    end

    it "should 404 for other user" do
      other_user = create(:user)
      sign_in user
      get blocked_user_path(other_user)
      assert_equal 404, response.status
    end
  end

  describe "GET /users/:id/follow" do
    it "should work" do
      sign_in user
      other_user = create(:user)

      post follow_user_path(other_user)
      assert_equal 200, response.status
      assert_equal true, user.follow_user?(other_user)
    end
  end

  describe ":unfollow" do
    it "should work" do
      sign_in user
      other_user = create(:user)
      user.follow_user(other_user)

      post unfollow_user_path(other_user)
      assert_equal 200, response.status
      assert_equal false, user.follow_user?(other_user)
    end
  end

  describe "GET /users/:id/followers" do
    it "should work" do
      get followers_user_path(user)
      assert_equal 200, response.status
    end
  end

  describe ":following" do
    it "should work" do
      get following_user_path(user)
      assert_equal 200, response.status
    end
  end

  describe "GET /users/city/:city" do
    it "should render 404 if there is no user in that city" do
      get location_users_path("Mars")
      assert_equal 404, response.status
    end

    it "should show user associated with that city" do
      get location_users_path(user.location)
      assert_equal 200, response.status
    end
  end

  describe "GET /users/:id/reward" do
    it "should not allow user close" do
      user.update_reward_fields(alipay: "XXXXXXX")

      get reward_user_path(user), xhr: true
      assert_equal 200, response.status
      assert_includes response.body, "XXXXXXX"
    end
  end
end
