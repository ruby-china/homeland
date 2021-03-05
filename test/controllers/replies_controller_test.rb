# frozen_string_literal: true

require "spec_helper"

describe RepliesController, type: :controller do
  describe "GET /topics/:id/replies" do
    it "should work" do
      user = create :user
      topic = create :topic
      replies = create_list :reply, 3

      sign_in user
      get topic_replies_path(topic), params: {last_id: replies.first.id}, xhr: true
      assert_equal 200, response.status
      assert_equal 0, user.notifications.unread.count
    end

    it "render blank for params last_id 0" do
      topic = create :topic
      create_list :reply, 3
      get topic_replies_path(topic), params: {last_id: 0}, xhr: true
      assert_equal 200, response.status
      assert_equal "", response.body
    end
  end

  describe "POST /topics/:id/replies" do
    it "should error if save fail" do
      user = create :user
      topic = create :topic
      assert_equal false, user.topic_read?(topic)

      create :reply, topic: topic
      sign_in user
      post topic_replies_path(topic), params: {reply: {body: ""}, format: :js}
      assert_equal 200, response.status
      assert_match(/Reply Content can't be blank/, response.body)
      assert_equal false, user.topic_read?(topic)
    end

    it "should create reply and set topic read" do
      user = create :user
      topic = create :topic
      assert_equal false, user.topic_read?(topic)

      sign_in user

      create :reply, topic: topic
      perform_enqueued_jobs do
        post topic_replies_path(topic), params: {reply: {body: "content"}, format: :js}
        assert_equal 200, response.status
      end
      topic.reload
      assert_equal true, user.topic_read?(topic)
    end
  end

  describe "POST /topics/:id/replies/:id" do
    let(:topic) { create :topic }
    let(:user) { create :user }
    let(:reply) { create :reply, user: user, topic: topic }

    it "should not change topic's last reply info to previous one" do
      sign_in user
      post topic_reply_path(topic, reply), params: {reply: {body: "content"}, format: :js}
      assert_equal user.login, topic.reload.last_reply_user_login
    end
  end

  describe "DELETE /replies/:id" do
    let(:topic) { create :topic }
    let(:admin) { create :admin }
    let(:user) { create :user }
    let(:user1) { create :user }
    let(:reply) { create :reply, user: user, topic: topic }
    let(:reply1) { create :reply, user: user1, topic: topic }

    it "should require login to destroy reply" do
      delete topic_reply_path(topic, reply)
      refute_equal 200, response.status
    end

    it "user1 should not allow destroy reply" do
      sign_in user1
      delete topic_reply_path(topic, reply)
      refute_equal 200, response.status
    end

    it "user should destroy reply with itself" do
      sign_in user
      delete topic_reply_path(topic, reply)
      assert_redirected_to topic_path(topic)
    end

    it "admin should destroy reply" do
      sign_in admin
      delete topic_reply_path(topic, reply)
      assert_redirected_to topic_path(topic)

      delete topic_reply_path(topic, reply1)
      assert_redirected_to topic_path(topic)
    end

    it "should redirect if failure" do
      Reply.any_instance.stubs(:destroy).returns(false)
      sign_in user
      delete topic_reply_path(topic, reply)
      assert_redirected_to topic_path(topic)
    end
  end

  describe "#reply_to" do
    let(:topic) { create :topic }
    let(:reply1) { create :reply, topic: topic }
    let(:reply) { create :reply, topic: topic, reply_to: reply1 }

    it "should work" do
      get reply_to_topic_reply_path(topic, reply1)
      assert_equal 404, response.status

      get reply_to_topic_reply_path(topic, reply), xhr: true
      assert_equal 200, response.status
    end
  end
end
