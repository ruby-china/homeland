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
      expect(response).to have_http_status(200)
      expect(user.notifications.unread.count).to eq 0
    end

    it "render blank for params last_id 0" do
      topic = create :topic
      replies = create_list :reply, 3
      get :index, params: { topic_id: topic.id, last_id: 0 }, xhr: true
      expect(response).to have_http_status(200)
      expect(response.body).to eq ""
    end
  end

  describe "#create" do
    it "should error if save fail" do
      user = create :user
      topic = create :topic
      expect(user.topic_read?(topic)).to be_falsey

      create :reply, topic: topic
      sign_in user
      post :create, params: { topic_id: topic.id, reply: { body: "" } }, format: :js
      expect(response).to have_http_status(200)
      expect(response.body).to match(/回复内容不能为空字符/)
      expect(user.topic_read?(topic)).to be_falsey
    end

    it "should create reply and set topic read" do
      user = create :user
      topic = create :topic
      expect(user.topic_read?(topic)).to be_falsey

      create :reply, topic: topic
      sign_in user
      post :create, params: { topic_id: topic.id, reply: { body: "content" } }, format: :js
      expect(response).to have_http_status(200)
      expect(user.topic_read?(topic)).to be_truthy
    end
  end

  describe "#update" do
    let(:topic) { create :topic }
    let(:user) { create :user }
    let(:reply) { create :reply, user: user, topic: topic }

    it "should not change topic's last reply info to previous one" do
      sign_in user
      post :update, params: { topic_id: topic.id, id: reply.id, reply: { body: "content" } }, format: :js
      expect(topic.reload.last_reply_user_login).to eq user.login
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
      expect(response).not_to have_http_status(200)
    end

    it "user1 should not allow destroy reply" do
      sign_in user1
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      expect(response).not_to have_http_status(200)
    end

    it "user should destroy reply with itself" do
      sign_in user
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      expect(response).to redirect_to(topic_path(topic))
    end

    it "admin should destroy reply" do
      sign_in admin
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      expect(response).to redirect_to(topic_path(topic))

      delete :destroy, params: { topic_id: topic.id, id: reply1.id }
      expect(response).to redirect_to(topic_path(topic))
    end

    it "should redirect if failure" do
      allow_any_instance_of(Reply).to receive(:destroy).and_return(false)

      sign_in user
      delete :destroy, params: { topic_id: topic.id, id: reply.id }
      expect(response).to redirect_to(topic_path(topic))
    end
  end

  describe "#reply_to" do
    let(:topic) { create :topic }
    let(:reply1) { create :reply, topic: topic }
    let(:reply) { create :reply, topic: topic, reply_to: reply1 }

    it "should work" do
      get :reply_to, params: { topic_id: topic.id, id: reply.id }
      expect(response.status).to eq 404
      get :reply_to, params: { topic_id: topic.id, id: reply.id }, xhr: true
      expect(response).to have_http_status(200)
    end
  end
end
