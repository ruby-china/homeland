# frozen_string_literal: true

require "spec_helper"

describe Api::V3::TopicsController do
  describe "GET /api/v3/topics.json" do
    it "should be ok" do
      get "/api/v3/topics.json"
      assert_equal 200, response.status
    end

    it "should be ok for all types" do
      create(:topic, title: "This is a normal topic", replies_count: 1)
      create(:topic, title: "This is an excellent topic", grade: :excellent, replies_count: 1)
      create(:topic, title: "This is a no_reply topic", replies_count: 0)
      create(:topic, title: "This is a popular topic", replies_count: 1, likes_count: 10)

      node = create(:node, name: "No Point")
      create(:topic, title: "This is a No Point topic", node: node)
      Setting.node_ids_hide_in_topics_index = node.id.to_s

      get "/api/v3/topics.json"
      json1 = JSON.parse(response.body)
      assert_equal 200, response.status

      assert_equal 4, json1["topics"].size
      fields = %w[id title created_at updated_at replied_at
        replies_count node_name node_id last_reply_user_id
        last_reply_user_login deleted excellent likes_count]
      assert_has_keys json1["topics"][0], *fields
      titles = json1["topics"].map { |topic| topic["title"] }
      assert_includes titles, "This is a normal topic"
      assert_includes titles, "This is an excellent topic"
      assert_includes titles, "This is a no_reply topic"
      assert_includes titles, "This is a popular topic"

      get "/api/v3/topics.json", type: "invalid_type"
      assert_equal 200, response.status
      json2 = JSON.parse(response.body)
      assert_equal json1, json2

      get "/api/v3/topics.json", type: "recent"
      assert_equal 200, response.status

      assert_equal 4, json["topics"].size
      assert_equal "This is a popular topic", json["topics"][0]["title"]
      assert_equal "This is a no_reply topic", json["topics"][1]["title"]

      get "/api/v3/topics.json", type: "excellent"
      assert_equal 200, response.status

      assert_equal 1, json["topics"].size
      assert_equal "This is an excellent topic", json["topics"][0]["title"]

      get "/api/v3/topics.json", type: "no_reply"

      assert_equal 200, response.status
      assert_equal 1, json["topics"].size
      assert_equal "This is a no_reply topic", json["topics"][0]["title"]

      get "/api/v3/topics.json", type: "popular"
      assert_equal 200, response.status

      assert_equal 1, json["topics"].size
      assert_equal "This is a popular topic", json["topics"][0]["title"]

      get "/api/v3/topics.json", type: "recent"
      assert_equal 200, response.status

      assert_equal 4, json["topics"].size
      assert_equal "This is a popular topic", json["topics"][0]["title"]
      assert_equal "This is a no_reply topic", json["topics"][1]["title"]
      assert_equal "This is an excellent topic", json["topics"][2]["title"]
      assert_equal "This is a normal topic", json["topics"][3]["title"]
    end

    describe "with logined user" do
      it "should hide user blocked nodes/users" do
        user = create(:user)
        node = create(:node)
        create(:topic, user: user)
        create(:topic, node: node)
        t3 = create(:topic)
        current_user.block_user(user.id)
        current_user.block_node(node.id)
        login_user!

        get "/api/v3/topics.json"
        assert_equal 1, json["topics"].size
        assert_equal t3.id, json["topics"][0]["id"]
      end
    end
  end

  describe "GET /api/v3/topics.json with node_id" do
    let(:node) { create(:node) }
    let(:node1) { create(:node) }

    let(:t1) { create(:topic, node_id: node.id, title: "This is a normal topic", replies_count: 1) }
    let(:t2) { create(:topic, node_id: node.id, title: "This is an excellent topic", grade: :excellent, replies_count: 1) }
    let(:t3) { create(:topic, node_id: node.id, title: "This is a no_reply topic", replies_count: 0) }
    let(:t4) { create(:topic, node_id: node.id, title: "This is a popular topic", replies_count: 1, likes_count: 10) }
    let(:t5) { create(:topic, node_id: node.id, title: "This is an excellent topic", grade: :ban, replies_count: 1) }

    it "should return a list of topics that belong to the specified node" do
      other_topics = [create(:topic, node_id: node1.id), create(:topic, node_id: node1.id)]
      topics = [t1, t2, t3, t4]

      get "/api/v3/topics.json", node_id: -1
      assert_equal 404, response.status

      get "/api/v3/topics.json", node_id: node.id

      assert_equal 200, response.status
      assert_equal 4, json["topics"].size
      json_titles = json["topics"].map { |t| t["id"] }
      topics.each do |t|
        assert_equal true, json_titles.include?(t.id)
      end
      other_topics.each do |t|
        assert_equal false, json_titles.include?(t.id)
      end

      get "/api/v3/topics.json", node_id: node.id, type: "excellent"
      assert_equal 200, response.status

      assert_equal 1, json["topics"].size
      assert_equal "This is an excellent topic", json["topics"][0]["title"]

      get "/api/v3/topics.json", node_id: node.id, type: "no_reply"
      assert_equal 200, response.status

      assert_equal 1, json["topics"].size
      assert_equal "This is a no_reply topic", json["topics"][0]["title"]

      get "/api/v3/topics.json", node_id: node.id, type: "popular"
      assert_equal 200, response.status

      assert_equal 1, json["topics"].size
      assert_equal "This is a popular topic", json["topics"][0]["title"]

      get "/api/v3/topics.json", node_id: node.id, type: "recent"
      assert_equal 200, response.status

      assert_equal 4, json["topics"].size
      assert_equal "This is a popular topic", json["topics"][0]["title"]
      assert_equal "This is a no_reply topic", json["topics"][1]["title"]
      assert_equal "This is an excellent topic", json["topics"][2]["title"]
      assert_equal "This is a normal topic", json["topics"][3]["title"]

      t1.update(last_active_mark: 4)
      t2.update(last_active_mark: 3)
      t3.update(last_active_mark: 2)
      t4.update(last_active_mark: 1)

      get "/api/v3/topics.json", node_id: node.id, limit: 2
      assert_equal 200, response.status

      assert_equal 2, json["topics"].size
      assert_equal "This is a normal topic", json["topics"][0]["title"]
      assert_equal "This is an excellent topic", json["topics"][1]["title"]

      get "/api/v3/topics.json", node_id: node.id, offset: 0, limit: 2
      assert_equal 200, response.status

      assert_equal 2, json["topics"].size
      assert_equal "This is a normal topic", json["topics"][0]["title"]
      assert_equal "This is an excellent topic", json["topics"][1]["title"]

      get "/api/v3/topics.json", offset: 2, limit: 2, node_id: node.id
      assert_equal 200, response.status

      assert_equal 2, json["topics"].size
      assert_equal "This is a no_reply topic", json["topics"][0]["title"]
      assert_equal "This is a popular topic", json["topics"][1]["title"]
    end
  end

  describe "POST /api/v3/topics.json" do
    it "should require user" do
      post "/api/v3/topics.json", title: "api create topic", body: "here we go", node_id: 1
      assert_equal 401, response.status
    end

    it "should work" do
      login_user!
      node_id = create(:node).id
      post "/api/v3/topics.json", title: "api create topic", body: "here we go", node_id: node_id
      assert_equal 200, response.status
      assert_equal "<p>here we go</p>", json["topic"]["body_html"]

      last_topic = current_user.reload.topics.first

      assert_equal "api create topic", last_topic.title
      assert_equal node_id, last_topic.node_id
    end
  end

  describe "POST /api/v3/topics/:id.json" do
    let(:topic) { create(:topic) }

    it "should require user" do
      post "/api/v3/topics/#{topic.id}.json", title: "api create topic", body: "here we go", node_id: 1
      assert_equal 401, response.status
    end

    it "should return 403 when topic owner is now current_user, and not admin" do
      login_user!
      post "/api/v3/topics/#{topic.id}.json", title: "api create topic", body: "here we go", node_id: 1
      assert_equal 403, response.status
    end

    it "should update with admin user" do
      new_node = create(:node)
      login_admin!
      post "/api/v3/topics/#{topic.id}.json", title: "api create topic", body: "here we go", node_id: new_node.id
      assert_equal 200, response.status
      topic.reload
      assert_equal true, topic.lock_node
    end

    describe "with user" do
      let(:topic) { create(:topic, user: current_user) }

      it "should work" do
        login_user!
        node_id = create(:node).id
        post "/api/v3/topics/#{topic.id}.json", title: "api create topic", body: "here we go", node_id: node_id
        assert_equal 200, response.status
        assert_equal "<p>here we go</p>", json["topic"]["body_html"]

        last_topic = current_user.reload.topics.first

        assert_equal "api create topic", last_topic.title
        assert_equal "here we go", last_topic.body
        assert_equal node_id, last_topic.node_id
      end

      it "should node update node_id when topic is lock_node" do
        topic.update_attribute(:lock_node, true)
        login_user!
        node_id = create(:node).id
        post "/api/v3/topics/#{topic.id}.json", title: "api create topic", body: "here we go", node_id: node_id
        topic.reload
        refute_equal node_id, topic.node_id
      end
    end
  end

  describe "DELETE /api/v3/topics/:id.json" do
    let(:topic) { create(:topic) }

    it "should require user" do
      delete "/api/v3/topics/#{topic.id}.json"
      assert_equal 401, response.status
    end

    it "should return 404 when topic not found" do
      login_user!
      delete "/api/v3/topics/abc.json"
      assert_equal 404, response.status
    end

    it "should return 403 when topic owner is now current_user, and not admin" do
      login_user!
      delete "/api/v3/topics/#{topic.id}.json"
      assert_equal 403, response.status
    end

    it "should destroy with topic owner user" do
      login_user!
      topic = create(:topic, user: current_user)
      delete "/api/v3/topics/#{topic.id}.json"
      assert_equal 200, response.status
      topic.reload
      assert_equal true, topic.deleted?
    end

    it "should destroy with admin user" do
      login_admin!
      delete "/api/v3/topics/#{topic.id}.json"
      assert_equal 200, response.status
      topic.reload
      assert_equal true, topic.deleted?
    end
  end

  describe "GET /api/v3/topics/:id.json" do
    it "should get topic detail with list of replies" do
      t = create(:topic, title: "i want to know")
      get "/api/v3/topics/#{t.id}.json"
      assert_equal 200, response.status
      fields = %w[id title created_at updated_at replied_at body body_html
        replies_count node_name node_id last_reply_user_id
        last_reply_user_login deleted user likes_count suggested_at closed_at]

      assert_has_keys json["topic"], *fields
      assert_has_keys json["meta"], "liked", "favorited", "followed"
      assert_equal "i want to know", json["topic"]["title"]
      assert_equal 0, json["topic"]["excellent"]
      assert_equal "normal", json["topic"]["grade"]
      assert_has_keys json["topic"]["user"], "id", "name", "login", "avatar_url"
      assert_has_keys json["topic"]["abilities"], "update", "destroy"
      assert_equal false, json["topic"]["abilities"]["update"]
      assert_equal false, json["topic"]["abilities"]["destroy"]
      assert_equal false, json["topic"]["abilities"]["ban"]
      assert_equal false, json["topic"]["abilities"]["excellent"]
      assert_equal false, json["topic"]["abilities"]["unexcellent"]
      assert_equal false, json["topic"]["abilities"]["normal"]
      assert_equal false, json["topic"]["abilities"]["close"]
      assert_equal false, json["topic"]["abilities"]["open"]
    end

    it "should return right abilities when owner visit" do
      t = create(:topic, user: current_user)
      login_user!
      get "/api/v3/topics/#{t.id}.json"
      assert_equal 200, response.status
      assert_equal true, json["topic"]["abilities"]["update"]
      assert_equal true, json["topic"]["abilities"]["destroy"]
      assert_equal true, json["topic"]["abilities"]["close"]
      assert_equal true, json["topic"]["abilities"]["open"]
    end

    it "should return right abilities when admin visit" do
      t = create(:topic)
      login_admin!
      get "/api/v3/topics/#{t.id}.json"
      assert_equal 200, response.status
      assert_equal true, json["topic"]["abilities"]["update"]
      assert_equal true, json["topic"]["abilities"]["destroy"]
      assert_equal true, json["topic"]["abilities"]["close"]
      assert_equal true, json["topic"]["abilities"]["open"]
      assert_equal true, json["topic"]["abilities"]["ban"]
      assert_equal true, json["topic"]["abilities"]["excellent"]
      assert_equal true, json["topic"]["abilities"]["unexcellent"]
      assert_equal true, json["topic"]["abilities"]["normal"]
    end

    it "should work when id record found" do
      get "/api/v3/topics/-1.json"
      assert_equal 404, response.status
    end

    describe "liked, followed, favorited" do
      let(:topic) { create(:topic) }

      it "should work" do
        login_user!
        current_user.like(topic)
        current_user.favorite_topic(topic.id)
        get "/api/v3/topics/#{topic.id}.json"
        assert_equal 200, response.status
        assert_has_keys json["meta"], "liked", "favorited", "followed"
        assert_equal true, json["meta"]["liked"]
        assert_equal true, json["meta"]["favorited"]
        assert_equal false, json["meta"]["followed"]
      end
    end
  end

  describe "GET /api/v3/topic/:id/replies.json" do
    it "without login should work" do
      t = create(:topic, title: "i want to know")
      create(:reply, topic_id: t.id, body: "let me tell", user: current_user)
      create(:reply, topic_id: t.id, body: "let me tell again", deleted_at: Time.now)
      get "/api/v3/topics/#{t.id}/replies.json"
      assert_equal 200, response.status
      assert_equal 2, json["replies"].size
      assert_equal [], json["meta"]["user_liked_reply_ids"]
    end

    it "with logined should work" do
      login_user!
      t = create(:topic, title: "i want to know")
      r0 = create(:reply)
      r1 = create(:reply, topic_id: t.id, body: "let me tell", user: current_user)
      r2 = create(:reply, topic_id: t.id, body: "let me tell again", deleted_at: Time.now)
      r3 = create(:reply, topic_id: t.id, body: "let me tell again again")
      current_user.like(r0)
      current_user.like(r2)
      current_user.like(r3)
      get "/api/v3/topics/#{t.id}/replies.json"
      assert_equal 200, response.status
      assert_equal 3, json["replies"].size
      assert_has_keys json["replies"][0], "id", "user", "body_html", "created_at", "updated_at", "deleted"
      assert_has_keys json["replies"][0]["user"], "id", "name", "login", "avatar_url"
      assert_equal r1.id, json["replies"][0]["id"]
      assert_has_keys json["replies"][0]["abilities"], "update", "destroy"
      assert_equal true, json["replies"][0]["abilities"]["update"]
      assert_equal true, json["replies"][0]["abilities"]["destroy"]
      assert_equal r2.id, json["replies"][1]["id"]
      assert_equal true, json["replies"][1]["deleted"]
      assert_equal false, json["replies"][1]["abilities"]["update"]
      assert_equal false, json["replies"][1]["abilities"]["destroy"]
      assert_equal false, json["meta"]["user_liked_reply_ids"].include?(r0.id)
      assert_equal true, json["meta"]["user_liked_reply_ids"].include?(r2.id)
      assert_equal true, json["meta"]["user_liked_reply_ids"].include?(r3.id)
    end

    it "admin login should return right abilities when admin visit" do
      login_admin!
      t = create(:topic, title: "i want to know")
      create(:reply, topic_id: t.id, body: "let me tell")
      create(:reply, topic_id: t.id, body: "let me tell again", deleted_at: Time.now)
      get "/api/v3/topics/#{t.id}/replies.json"
      assert_equal 200, response.status
      assert_equal true, json["replies"][0]["abilities"]["update"]
      assert_equal true, json["replies"][0]["abilities"]["destroy"]
      assert_equal true, json["replies"][1]["abilities"]["update"]
      assert_equal true, json["replies"][1]["abilities"]["destroy"]
    end
  end

  describe "POST /api/v3/topics/:id/replies.json" do
    it "should post a new reply" do
      login_user!
      t = create(:topic, title: "new topic 1")
      post "/api/v3/topics/#{t.id}/replies.json", body: "new reply body"
      assert_equal 200, response.status
      assert_equal "new reply body", t.reload.replies.first.body
    end

    it "should not create Reply when Topic was closed" do
      login_user!
      t = create(:topic, title: "new topic 1", closed_at: Time.now)
      post "/api/v3/topics/#{t.id}/replies.json", body: "new reply body"
      assert_equal 400, response.status
      assert_includes json["message"], "Topic has been closed, no longer accepting create or update replies."
      assert_nil t.reload.replies.first
    end
  end

  describe "POST /api/v3/topics/:id/follow.json" do
    it "should follow a topic" do
      login_user!
      t = create(:topic, title: "new topic 2")
      post "/api/v3/topics/#{t.id}/follow.json"
      assert_equal 200, response.status
      assert_equal true, t.reload.follow_by_user_ids.include?(current_user.id)
    end
  end

  describe "POST /api/v3/topics/:id/unfollow.json" do
    it "should unfollow a topic" do
      login_user!
      t = create(:topic, title: "new topic 2")
      post "/api/v3/topics/#{t.id}/unfollow.json"
      assert_equal 200, response.status
      assert_equal false, t.reload.follow_by_user_ids.include?(current_user.id)
    end
  end

  describe "POST /api/v3/topics/:id/favorite.json" do
    it "should favorite a topic" do
      login_user!
      t = create(:topic, title: "new topic 3")
      post "/api/v3/topics/#{t.id}/favorite.json"
      assert_equal 200, response.status
      assert_equal true, current_user.reload.favorite_topic_ids.include?(t.id)
    end
  end

  describe "POST /api/v3/topics/:id/unfavorite.json" do
    it "should unfavorite a topic" do
      login_user!
      t = create(:topic, title: "new topic 3")
      post "/api/v3/topics/#{t.id}/unfavorite.json"
      assert_equal 200, response.status
      assert_equal false, current_user.reload.favorite_topic_ids.include?(t.id)
    end
  end

  describe "POST /api/v3/topics/:id/ban.json" do
    it "should work with admin" do
      login_admin!
      t = create(:topic, user: current_user, title: "new topic 3")
      post "/api/v3/topics/#{t.id}/ban.json"
      assert_equal 200, response.status
    end

    it "should not ban a topic with normal user" do
      login_user!
      t = create(:topic, title: "new topic 3")
      post "/api/v3/topics/#{t.id}/ban.json"
      assert_equal 403, response.status

      t = create(:topic, user: current_user, title: "new topic 3")
      post "/api/v3/topics/#{t.id}/ban.json"
      assert_equal 403, response.status
    end
  end

  describe "POST /api/v3/topics/:id/action.json" do
    %w[excellent normal unexcellent ban].each do |action|
      describe action.to_s do
        it "should work with admin" do
          login_admin!
          t = create(:topic, user: current_user, title: "new topic 3")
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          assert_equal 200, response.status
        end

        it "should not work with normal user" do
          login_user!
          t = create(:topic, title: "new topic 3")
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          assert_equal 403, response.status

          t = create(:topic, user: current_user, title: "new topic 3")
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          assert_equal 403, response.status
        end
      end
    end

    %w[close open].each do |action|
      describe action.to_s do
        it "should work with admin" do
          login_admin!
          t = create(:topic, user: current_user, title: "new topic 3")
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          assert_equal 200, response.status
        end

        it "should work with owner" do
          login_user!
          t = create(:topic, title: "new topic 3", user: current_user)
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          assert_equal 200, response.status
        end

        it "should not work with other users" do
          login_user!
          t = create(:topic, title: "new topic 3")
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          assert_equal 403, response.status
        end
      end
    end
  end
end
