# frozen_string_literal: true

require "spec_helper"

describe Api::V3::UsersController do
  describe "GET /api/v3/users.json" do
    before do
      @users = create_list(:user, 10)

      @users.each do |user|
        user.yearly_replies_count.to_i
        user.monthly_replies_count.to_i
      end
    end

    it "should work" do
      get "/api/v3/users.json"
      assert_equal 200, response.status
      assert_equal @users.count, json["users"].size
      assert_has_keys json["users"][0], "id", "name", "login", "avatar_url"
    end

    it "should work :limit" do
      get "/api/v3/users.json", limit: 2
      assert_equal 200, response.status
      assert_equal 2, json["users"].size
    end
  end

  describe "GET /api/v3/users/me.json" do
    it "should 403 when not login" do
      get "/api/v3/users/me.json"
      assert_equal 401, response.status
    end

    it "should work" do
      login_user!
      get "/api/v3/users/me.json"
      assert_equal 200, response.status
      assert_equal current_user.login, json["user"]["login"]
      assert_equal current_user.email, json["user"]["email"]
    end
  end

  describe "GET /api/v3/users/:login.json" do
    it "should get user details with list of topics" do
      user = create(:user, name: "test user", login: "test_user", email: "foobar@gmail.com", bio: "hello world", email_public: true)
      get "/api/v3/users/test_user.json"
      assert_equal 200, response.status
      fields = %w[id name login email avatar_url location company twitter github website bio tagline
        topics_count replies_count following_count followers_count favorites_count
        level level_name]

      assert_has_keys json["user"], *fields
      fields.reject { |f| f.in? %w[avatar_url bio] }.each do |field|
        val = user.send(field)
        if val.nil?
          assert_nil json["user"][field]
        else
          assert_equal val, json["user"][field]
        end
      end
      assert_equal "", json["user"]["bio"]
      assert_has_keys json["meta"], "blocked", "followed"
    end

    it "should hidden email when email_public is false" do
      create(:user, name: "test user", login: "test_user", email: "foobar@gmail.com", email_public: false)
      get "/api/v3/users/test_user.json"
      assert_equal 200, response.status
      assert_equal "", json["user"]["email"]
    end

    it "should get right meta info" do
      u = create(:user, name: "test user", login: "test_user", email: "foobar@gmail.com", email_public: false)
      login_user!
      current_user.follow_user(u)
      current_user.block_user(u.id)
      get "/api/v3/users/test_user.json"
      assert_equal 200, response.status
      assert_equal true, json["meta"]["blocked"]
      assert_equal true, json["meta"]["followed"]
    end

    it "should not hidden email when current_user itself" do
      login_user!
      get "/api/v3/users/#{current_user.login}.json"
      assert_equal 200, response.status
      assert_equal current_user.email, json["user"]["email"]
    end
  end

  describe "GET /api/v3/users/:login/topics.json" do
    let(:user) { create(:user) }

    describe "recent order" do
      it "should work" do
        @topics = create_list(:topic, 3, user:)
        get "/api/v3/users/#{user.login}/topics.json", offset: 0, limit: 2
        assert_equal 200, response.status
        assert_equal 2, json["topics"].size
        fields = %w[id title user node_name node_id last_reply_user_id last_reply_user_login created_at updated_at replies_count]
        assert_has_keys json["topics"][0], *fields
        assert_equal @topics[2].id, json["topics"][0]["id"]
        assert_equal @topics[1].id, json["topics"][1]["id"]
      end
    end

    describe "hot order" do
      it "should work" do
        @hot_topic = create(:topic, user:, likes_count: 4)
        @topics = create_list(:topic, 3, user:)

        get "/api/v3/users/#{user.login}/topics.json", order: "likes", offset: 0, limit: 3
        assert_equal 200, response.status
        assert_equal 3, json["topics"].size
        assert_equal @hot_topic.id, json["topics"][0]["id"]
      end
    end

    describe "hot order" do
      it "should work" do
        @hot_topic = create(:topic, user:, replies_count: 4)
        @topics = create_list(:topic, 3, user:)

        get "/api/v3/users/#{user.login}/topics.json", order: "replies", offset: 0, limit: 3
        assert_equal 200, response.status
        assert_equal 3, json["topics"].size
        assert_equal @hot_topic.id, json["topics"][0]["id"]
      end
    end
  end

  describe "GET /api/v3/users/:login/replies.json" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic, title: "Test topic title") }

    describe "recent order" do
      it "should work" do
        @replies = create_list(:reply, 3, user:, topic:)
        get "/api/v3/users/#{user.login}/replies.json", offset: 0, limit: 2
        assert_equal 2, json["replies"].size
        fields = %w[id user body_html topic_id topic_title]
        assert_has_keys json["replies"][0], *fields
        assert_equal @replies[2].id, json["replies"][0]["id"]
        assert_equal topic.title, json["replies"][0]["topic_title"]
        assert_equal @replies[1].id, json["replies"][1]["id"]
      end
    end
  end

  describe "GET /api/v3/users/:login/favorites.json" do
    let(:user) { create(:user) }

    it "should work" do
      @topics = create_list(:topic, 4, user:)
      user.favorite_topic(@topics[0].id)
      user.favorite_topic(@topics[1].id)
      user.favorite_topic(@topics[3].id)
      get "/api/v3/users/#{user.login}/favorites.json", offset: 1, limit: 2
      assert_equal 200, response.status
      assert_equal 2, json["topics"].size
      fields = %w[id title user node_name node_id last_reply_user_id
        last_reply_user_login created_at updated_at replies_count]
      assert_has_keys json["topics"][0], *fields
      assert_equal @topics[1].id, json["topics"][0]["id"]
      assert_equal @topics[0].id, json["topics"][1]["id"]
    end
  end

  describe "GET /api/v3/users/:login/followers.json" do
    let(:user) { create(:user) }

    it "should work" do
      @users = create_list(:user, 3)
      @users.map { |u| u.follow_user(user) }

      get "/api/v3/users/#{user.login}/followers.json", offset: 0, limit: 2
      assert_equal 200, response.status
      assert_equal 2, json["followers"].size
      assert_has_keys json["followers"][0], "id", "name", "login", "avatar_url"
      assert_equal @users[0].login, json["followers"][0]["login"]
    end
  end

  describe "GET /api/v3/users/:login/blocked.json" do
    let(:user) { create(:user) }

    it "require login" do
      get "/api/v3/users/#{user.login}/blocked.json"
      assert_equal 401, response.status
    end

    it "only visit itself" do
      login_user!
      get "/api/v3/users/#{user.login}/blocked.json"
      assert_equal 403, response.status
    end

    it "should work" do
      @users = create_list(:user, 3)
      login_user!

      @users.each do |u|
        current_user.block_user(u.id)
      end

      get "/api/v3/users/#{current_user.login}/blocked.json", offset: 0, limit: 2
      assert_equal 200, response.status
      assert_equal 2, json["blocked"].size
      assert_has_keys json["blocked"][0], "id", "name", "login", "avatar_url"
      assert_equal @users[0].login, json["blocked"][0]["login"]
    end
  end

  describe "GET /api/v3/users/:login/following.json" do
    let(:user) { create(:user) }

    it "should work" do
      @users = create_list(:user, 3)
      @users.each do |u|
        user.follow_user(u)
      end

      get "/api/v3/users/#{user.login}/following.json", offset: 0, limit: 2
      assert_equal 200, response.status
      assert_equal 2, json["following"].size
      assert_has_keys json["following"][0], "id", "name", "login", "avatar_url"
      assert_equal @users[0].login, json["following"][0]["login"]
    end
  end

  describe "POST /api/v3/users/:login/follow.json / unfollow" do
    let(:user) { create(:user) }

    it "should 401 when nologin" do
      post "/api/v3/users/#{user.login}/follow.json"
      assert_equal 401, response.status

      post "/api/v3/users/#{user.login}/unfollow.json"
      assert_equal 401, response.status
    end

    it "should follow work" do
      login_user!
      post "/api/v3/users/#{user.login}/follow.json"
      assert_equal 200, response.status
      assert_equal 1, json["ok"]
      followed = current_user.follow_user?(user)
      assert_equal true, followed
    end

    it "should unfollow work" do
      login_user!
      current_user.follow_user(user)
      post "/api/v3/users/#{user.login}/unfollow.json"
      assert_equal 200, response.status
      assert_equal 1, json["ok"]
      followed = current_user.follow_user?(user)
      assert_equal false, followed
    end
  end

  describe "POST /api/v3/users/:login/block.json / unblock.json" do
    let(:user) { create(:user) }

    it "should 401 when nologin" do
      post "/api/v3/users/#{user.login}/block.json"
      assert_equal 401, response.status

      post "/api/v3/users/#{user.login}/unblock.json"
      assert_equal 401, response.status
    end

    it "should work" do
      login_user!
      post "/api/v3/users/#{user.login}/block.json"
      assert_equal 200, response.status
      assert_equal 1, json["ok"]
      current_user.reload
      assert_equal true, current_user.block_user?(user)
    end

    it "should unfollow" do
      login_user!
      current_user.block_user(user.id)
      post "/api/v3/users/#{user.login}/unblock.json"
      assert_equal 200, response.status
      assert_equal 1, json["ok"]
      current_user.reload
      assert_equal false, current_user.block_user?(user)
    end
  end
end
