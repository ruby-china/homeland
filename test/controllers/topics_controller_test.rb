# frozen_string_literal: true

require "spec_helper"

describe TopicsController do
  let(:topic) { create :topic, user: user }
  let(:user) { create :avatar_user }
  let(:newbie) { create :newbie }
  let(:node) { create :node }
  let(:admin) { create :admin }
  let(:team) { create :team }

  describe "GET /topics" do
    it "should have an index action" do
      get topics_path
      assert_equal 200, response.status
      assert_select "title", text: Setting.app_name
    end

    it "should work when login" do
      sign_in user
      get topics_path
      assert_equal 200, response.status
    end

    it "should 404 with non integer :page value" do
      get topics_path, params: {page: "2/*"}
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/feed" do
    it "should have a feed action" do
      get feed_topics_path
      assert_equal "application/xml; charset=utf-8", response.headers["Content-Type"]
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/last" do
    it "should have a recent action" do
      get last_topics_path
      assert_equal 200, response.status
      assert_select "title", text: "Newest · Topics · #{Setting.app_name}"
    end
  end

  describe "GET /topics/excellent" do
    it "should have a excellent action" do
      get excellent_topics_path
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/banned" do
    it "should have a banned action" do
      get banned_topics_path
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/favorites" do
    it "should have a recent action" do
      sign_in user
      get favorites_topics_path
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/node/:id" do
    it "should have a node action" do
      get node_topics_path(topic.node_id)
      assert_equal 200, response.status
      assert_select "title", text: "#{topic.node.name} · Topics · #{Setting.app_name}"
    end
  end

  describe "GET /topics/node_feed/:id" do
    it "should have a node_feed action" do
      get feed_node_topics_path(topic.node_id)
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/no_reply" do
    it "should have a no_reply action" do
      get no_reply_topics_path
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/last_reply" do
    it "should have a no_reply action" do
      get last_reply_topics_path
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/popular" do
    it "should have a popular action" do
      get popular_topics_path
      assert_equal 200, response.status
    end
  end

  describe "GET /topics/new" do
    describe "unauthenticated" do
      it "should not allow anonymous access" do
        get new_topic_path
        refute_equal 200, response.status
      end
    end

    describe "authenticated" do
      it "should allow access from authenticated user" do
        sign_in user
        get new_topic_path
        assert_equal 200, response.status
      end

      it "should render 404 for invalid node id" do
        sign_in user
        get new_topic_path, params: {node_id: (node.id + 1)}
        refute_equal 200, response.status
      end

      it "should not allow access from newbie user" do
        Setting.stubs(:newbie_limit_time).returns("100000")
        sign_in newbie
        get new_topic_path
        refute_equal 200, response.status
      end
    end
  end

  describe "GET /topics/:id/edit" do
    describe "unauthenticated" do
      it "should not allow anonymous access" do
        get edit_topic_path(topic)
        refute_equal 200, response.status
      end
    end

    describe "authenticated" do
      describe "own topic" do
        it "should allow access from authenticated user" do
          sign_in user
          get edit_topic_path(topic)
          assert_equal 200, response.status
          assert_equal true, response.body.include?('tb="edit-topic"')
        end
      end

      describe "other's topic" do
        it "should not allow edit other's topic" do
          other_user = create :user
          topic_of_other_user = create(:topic, user: other_user)
          sign_in user
          get edit_topic_path(topic_of_other_user)
          refute_equal 200, response.status
        end
      end
    end
  end

  describe "POST /topics" do
    describe "unauthenticated" do
      it "should not allow anonymous access" do
        post topics_path, params: {title: "Hello world"}
        refute_equal 200, response.status
      end
    end

    describe "authenticated" do
      it "should allow access from authenticated user" do
        sign_in user
        post topics_path, params: {format: :js, topic: {title: "new topic", body: "new body", node_id: node.id}}
        assert_equal 200, response.status
      end
      it "should allow access from authenticated user with team" do
        sign_in user
        post topics_path, params: {format: :js, topic: {title: "new topic", body: "new body", node_id: node.id, team_id: team.id}}
        assert_equal 200, response.status
      end
    end
  end

  describe "POST /topics/preview" do
    it "should work" do
      sign_in user
      post preview_topics_path, params: {format: :json, body: "new body"}
      assert_equal 200, response.status
    end
  end

  describe "PUT /topics/:id" do
    it "should work" do
      sign_in user
      topic = create :topic, user_id: user.id, title: "new title", body: "new body"
      put topic_path(topic), params: {format: :js, topic: {title: "new topic 2", body: "new body 2"}}
      assert_equal 200, response.status
    end

    it "should update with admin user" do
      sign_in admin
      put topic_path(topic), params: {format: :js, topic: {title: "new topic 2", body: "new body 2", node_id: node.id}}
      assert_equal 200, response.status
      topic.reload
      assert_equal true, topic.lock_node
    end
  end

  describe "DELETE /topics/:id" do
    it "should work" do
      sign_in user
      topic = create :topic, user_id: user.id, title: "new title", body: "new body"
      delete topic_path(topic)
      assert_redirected_to topics_path
    end
  end

  describe "POST /topics/:id/favorite" do
    it "should work" do
      sign_in user
      post favorite_topic_path(topic)
      assert_equal 200, response.status
      assert_equal "1", response.body
    end
  end

  describe "DELETE /topics/:id/unfavorite" do
    it "should work" do
      sign_in user
      delete unfavorite_topic_path(topic)
      assert_equal 200, response.status
      assert_equal "1", response.body
    end
  end

  describe "POST /topics/:id/follow" do
    it "should work" do
      sign_in user
      post follow_topic_path(topic)
      assert_equal 200, response.status
      assert_equal "1", response.body
    end
  end

  describe "DELETE /topics/:id/unfollow" do
    it "should work" do
      sign_in user
      delete unfollow_topic_path(topic)
      assert_equal 200, response.status
      assert_equal "1", response.body
    end
  end

  describe "GET /topics/:id" do
    it "should work" do
      user = create :user
      topic = create :topic, body: "@#{user.login}"
      create :reply, body: "@#{user.login}", topic: topic, like_by_user_ids: [user.id]
      get topic_path(topic)
      assert_equal 200, response.status
    end
  end

  describe "POST /topics/:id/read" do
    it "should work" do
      user = create :user
      topic = create :topic, body: "@#{user.login}"
      create :reply, body: "@#{user.login}", topic: topic, like_by_user_ids: [user.id]
      sign_in user
      perform_enqueued_jobs do
        assert_changes -> { user.notifications.unread.count }, -2 do
          post read_topic_path(topic)
        end
      end
      assert_equal 200, response.status
    end
  end

  describe "POST /topics/:id/action?type=excellent" do
    it "should not allow user suggest" do
      sign_in user
      post action_topic_path(topic), params: {type: "excellent"}
      assert_redirected_to root_path
      assert_equal false, topic.reload.excellent?
    end

    it "should not allow user suggest by admin" do
      sign_in admin
      post action_topic_path(topic), params: {type: "excellent"}
      assert_redirected_to topic_path(topic)
      assert_equal true, topic.reload.excellent?
    end
  end

  describe "POST /topics/:id/action?type=normal" do
    describe "suggested topic" do
      it "should not allow user suggest" do
        topic = create(:topic, grade: :excellent)
        sign_in user
        post action_topic_path(topic), params: {type: "normal"}
        assert_redirected_to root_path
        assert_equal true, topic.reload.excellent?
      end

      it "should not allow user suggest by admin" do
        topic = create(:topic, grade: :excellent)
        sign_in admin
        post action_topic_path(topic), params: {type: "normal"}
        assert_redirected_to topic_path(topic)
        assert_equal false, topic.reload.excellent?
      end
    end
  end

  describe "GET /topics/:id/ban" do
    it "should user not work" do
      sign_in user
      get ban_topic_path(topic), xhr: true
      assert_equal 302, response.status
    end

    it "should admin work" do
      sign_in admin
      get ban_topic_path(topic), xhr: true
      assert_equal 200, response.status
    end
  end

  describe "POST /topics/:id/action?type=ban" do
    it "should not allow user ban" do
      sign_in user
      post action_topic_path(topic), params: {type: "ban"}
      assert_redirected_to root_path
      assert_equal false, topic.reload.ban?
    end

    it "should allow by admin" do
      sign_in admin
      post action_topic_path(topic), params: {type: "ban"}
      assert_redirected_to topic_path(topic)
      assert_equal true, topic.reload.ban?

      assert_changes -> { topic.replies.count }, 1 do
        post action_topic_path(topic), params: {type: "ban", reason: "Foobar"}
      end
      assert_redirected_to topic_path(topic)
      r = topic.replies.last
      assert_equal "ban", r.action
      assert_equal "Foobar", r.body

      assert_changes -> { topic.replies.count }, 1 do
        post action_topic_path(topic), params: {type: "ban", reason: "Foobar", reason_text: "Barfoo"}
      end
      assert_redirected_to topic_path(topic)
      r = topic.replies.last
      assert_equal "ban", r.action
      assert_equal "Barfoo", r.body
    end
  end

  describe "POST /topics/:id/action?type=close" do
    it "should not allow user close" do
      sign_in user
      post action_topic_path(topic), params: {type: "close"}
      assert_redirected_to topic_path(topic)
      assert_equal false, topic.reload.ban?
    end

    it "should not allow user suggest by admin" do
      sign_in admin
      post action_topic_path(topic), params: {type: "close"}
      assert_redirected_to topic_path(topic)
      assert_equal true, topic.reload.closed_at.present?
    end
  end

  describe "POST /topics/:id/action?type=copen" do
    it "should not allow user close" do
      sign_in user
      post action_topic_path(topic), params: {type: "open"}
      assert_redirected_to topic_path(topic)
      assert_equal false, topic.reload.ban?
    end

    it "should not allow user suggest by admin" do
      sign_in admin
      topic.close!
      post action_topic_path(topic), params: {type: "open"}
      assert_redirected_to topic_path(topic)
      assert_nil topic.reload.closed_at
    end
  end
end
