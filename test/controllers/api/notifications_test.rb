# frozen_string_literal: true

require "spec_helper"

describe Api::V3::NotificationsController do
  describe "GET /api/notifications.json" do
    it "must require token" do
      get "/api/v3/notifications.json"
      assert_equal 401, response.status
    end

    it "should be ok" do
      login_user!
      get "/api/v3/notifications.json"
      assert_equal 200, response.status
    end

    it "should get notification for a mention in a reply" do
      topic = create :topic, user: current_user
      reply = create :reply, topic: topic, user: current_user, body: "Test to mention user"
      note = create :notification_mention, user: current_user, target: reply
      login_user!
      get "/api/v3/notifications.json"
      assert_equal 200, response.status
      assert_equal false, json["notifications"][0]["read"]
      assert_equal "Reply", json["notifications"][0]["mention_type"]
      assert_equal "<p>Test to mention user</p>", json["notifications"][0]["mention"]["body_html"]
      assert_equal topic.id, json["notifications"][0]["mention"]["topic_id"]
      assert_equal note.actor.login, json["notifications"][0]["actor"]["login"]
    end

    describe "NodeChanged" do
      let(:node) { create :node }
      let(:topic) { create :topic, user: current_user }

      it "should work" do
        login_user!
        create :notification_node_changed, user: current_user, target: topic, second_target: node
        get "/api/v3/notifications.json"
        # puts json['message']
        assert_equal 200, response.status
        assert_equal false, json["notifications"][0]["read"]
        assert_has_keys json["notifications"][0], "type", "topic", "node"
        assert_equal "NodeChanged", json["notifications"][0]["type"]
        assert_equal topic.id, json["notifications"][0]["topic"]["id"]
        assert_equal topic.title, json["notifications"][0]["topic"]["title"]
        assert_equal node.id, json["notifications"][0]["node"]["id"]
        assert_equal node.name, json["notifications"][0]["node"]["name"]
      end
    end

    it "should get notification for a topic" do
      login_user!
      u = create(:user)
      current_user.follow_user(u)
      topic = create :topic, user: u
      create :notification_topic, user: current_user, target: topic
      get "/api/v3/notifications.json"

      # puts json['message']
      assert_equal 200, response.status
      assert_equal false, json["notifications"][0]["read"]
      assert_equal topic.id, json["notifications"][0]["topic"]["id"]
    end

    it "should get notification for a reply" do
      login_user!
      topic = create :topic, user: current_user
      reply = create :reply, topic: topic, user: current_user, body: "Test to reply user"
      note = create :notification_topic_reply, user: current_user, target: reply, second_target: topic
      get "/api/v3/notifications.json"

      # puts json['message']
      assert_equal 200, response.status
      assert_equal false, json["notifications"][0]["read"]
      assert_equal "<p>Test to reply user</p>", json["notifications"][0]["reply"]["body_html"]
      assert_equal topic.id, json["notifications"][0]["reply"]["topic_id"]
      assert_equal note.actor.login, json["notifications"][0]["actor"]["login"]
    end

    it "should get notification for a mention in a topic" do
      login_user!
      node = create :node
      topic = create :topic, user: current_user, node: node, title: "Test to mention user in a topic"
      note = create :notification_mention, user: current_user, target: topic
      get "/api/v3/notifications.json"
      assert_equal 200, response.status

      assert_equal false, json["notifications"][0]["read"]
      assert_equal "Topic", json["notifications"][0]["mention_type"]
      assert_equal "Test to mention user in a topic", json["notifications"][0]["mention"]["title"]
      assert_equal node.name, json["notifications"][0]["mention"]["node_name"]
      assert_equal note.actor.login, json["notifications"][0]["actor"]["login"]
    end

    it "should return a list of notifications of the current user" do
      login_user!
      topic = create :topic, user: current_user
      replies = (0...10).map { |i| create :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      (0...10).map { |i| create :notification_mention, user: current_user, target: replies[i] }

      get "/api/v3/notifications.json"
      assert_equal 200, response.status

      assert_equal 10, json["notifications"].size
      json["notifications"].each_with_index { |item, i| item["mention"]["body"] == replies[i].body }

      get "/api/v3/notifications.json", limit: 5
      assert_equal 200, response.status

      assert_equal 5, json["notifications"].size
      json["notifications"].each_with_index { |item, i| item["mention"]["body"] == replies[i].body }

      get "/api/v3/notifications.json", offset: 5, limit: 5
      assert_equal 200, response.status

      assert_equal 5, json["notifications"].size
      json["notifications"].each_with_index { |item, i| item["mention"]["body"] == replies[i + 5].body }
    end
  end

  describe "POST /api/notifications/read.json" do
    it "must require token" do
      post "/api/v3/notifications/read.json", ids: [1, 2]
      assert_equal 401, response.status
    end

    it "should work" do
      login_user!
      topic = create :topic, user: current_user
      replies = (0...10).map { |i| create :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      (0...10).map { |i| create :notification_mention, user: current_user, target: replies[i] }
      post "/api/v3/notifications/read.json", ids: current_user.notifications.pluck(:id)
      assert_equal 200, response.status
      current_user.notifications.each do |item|
        assert_equal true, item.reload.read?
      end
    end
  end

  describe "GET /api/notifications/unread_count.json" do
    it "should 401 when not login" do
      get "/api/v3/notifications/unread_count.json"
      assert_equal 401, response.status
    end

    it "should get count" do
      login_user!
      create :notification_topic, user: current_user
      create :notification_topic, user: current_user, read_at: Time.now
      get "/api/v3/notifications/unread_count.json"
      assert_equal 200, response.status
      assert_equal 1, json["count"]
    end
  end

  describe "DELETE /api/notifications/all.json" do
    it "must require token" do
      delete "/api/v3/notifications/all.json"
      assert_equal 401, response.status
    end

    it "should delete all notifications of current user" do
      login_user!
      topic = create :topic, user: current_user
      replies = (0...10).map { |i| create :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      (0...10).map { |i| create :notification_mention, user: current_user, target: replies[i] }

      get "/api/v3/notifications.json"

      assert_equal 200, response.status
      assert_equal 10, json["notifications"].size

      delete "/api/v3/notifications/all.json"
      assert_equal 200, response.status

      get "/api/v3/notifications.json"
      assert_equal 200, response.status

      assert_equal [], json["notifications"]
    end
  end

  describe "DELETE /api/notifications/:id.json" do
    it "must require token" do
      delete "/api/v3/notifications/1.json"
      assert_equal 401, response.status
    end

    it "should delete the specified notification of current user" do
      login_user!
      topic = create :topic, user: current_user
      replies = (0...10).map { |i| create :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      mentions = (0...10).map { |i| create :notification_mention, user: current_user, target: replies[i] }

      get "/api/v3/notifications.json"

      assert_equal 200, response.status
      assert_equal 10, json["notifications"].size

      deleted_ids = mentions.map(&:id).select(&:odd?)

      deleted_ids.each do |i|
        delete "/api/v3/notifications/#{i}.json"
        assert_equal 200, response.status
      end

      get "/api/v3/notifications.json"

      assert_equal 200, response.status
      assert_equal 10 - deleted_ids.size, json["notifications"].size
      json["notifications"].map do |item|
        assert_equal false, deleted_ids.include?(item["id"])
      end
    end
  end
end
