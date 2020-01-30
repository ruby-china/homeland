# frozen_string_literal: true

require "rails_helper"

describe RepliesController, type: :controller do
  describe "#index" do
    it "should work" do
      user = create :user
      topic = create :topic
      replies = create_list :reply, 3

      sign_in user
      get :index, params: { topic_id: topic.id, last_id: replies.first.id }, xhr: true
      assert_equal 200, response.status
      assert_equal 0, user.notifications.unread.count
    end

    it "render blank for params last_id 0" do
      topic = create :topic
      replies = create_list :reply, 3
      get :index, params: { topic_id: topic.id, last_id: 0 }, xhr: true
      assert_equal 200, response.status
      assert_equal "", response.body
    end
  end

  describe "#create" do
    it "should error if save fail" do
      user = create :user
      topic = create :topic
      assert_equal false, user.topic_read?(topic)

      create :reply, topic: topic
      sign_in user
      post :create, params: { topic_id: topic.id, reply: { body: "" } }, format: :js
      assert_equal 200, response.status
      assert_match /回复内容不能为空字符/, response.body
      assert_equal false, user.topic_read?(topic)
    end

    it "should create reply and set topic read" do
      user = create :user
      topic = create :topic
      assert_equal false, user.topic_read?(topic)

      create :reply, topic: topic
      sign_in user
      post :create, params: { topic_id: topic.id, reply: { body: "content" } }, format: :js
      assert_equal 200, response.status
      assert_equal true, user.topic_read?(topic)
    end
  end

  describe "#update" do
    let(:topic) { create :topic }
    let(:user) { create :user }
    let(:reply) { create :reply, user: user, topic: topic }

    it "should not change topic's last reply info to previous one" do
      sign_in user
      post :update, params: { topic_id: topic.id, id: reply.id, reply: { body: "content" } }, format: :js
      assert_equal user.login, topic.reload.last_reply_user_login
    end
  end

  describe "#destroy" do
    let(:topic) { create :topic }
    let(:admin) { create :admin }
    let(:user) { create :user }
    let(:user1) { create :user }
    let(:reply) { create :reply, user: user, topic: topic }
    let(:reply1) { create :reply, user: user1, topic: topic }

    it "should require login to destroy reply" do
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      refute_equal 200, response.status
    end

    it "user1 should not allow destroy reply" do
      sign_in user1
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      refute_equal 200, response.status
    end

    it "user should destroy reply with itself" do
      sign_in user
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      assert_redirected_to topic_path(topic)
    end

    it "admin should destroy reply" do
      sign_in admin
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      assert_redirected_to topic_path(topic)

      delete :destroy, params: { topic_id: topic.id, id: reply1.id }
      assert_redirected_to topic_path(topic)
    end

    it "should redirect if failure" do
      allow_any_instance_of(Reply).to receive(:destroy).and_return(false)

      sign_in user
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      assert_redirected_to topic_path(topic)
    end
  end

  describe "#reply_to" do
    let(:topic) { create :topic }
    let(:reply1) { create :reply, topic: topic }
    let(:reply) { create :reply, topic: topic, reply_to: reply1 }

    it "should work" do
      get :reply_to, params: { topic_id: topic.id, id: reply.id }
      assert_equal 404, response.status
      get :reply_to, params: { topic_id: topic.id, id: reply.id }, xhr: true
      assert_equal 200, response.status
    end
  end
end
