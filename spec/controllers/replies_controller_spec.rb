require 'spec_helper'

describe RepliesController do
  describe "#create" do
    it "should create reply and set topic read" do
      user = Factory :user
      topic = Factory :topic
      user.topic_read?(topic).should be_false

      Factory :reply, :topic => topic
      sign_in user
      post :create, :topic_id => topic.id, :reply => {:body => 'content'}, :format => :js
      topic.reload
      user.topic_read?(topic).should be_true
    end
  end
  
  describe "#destroy" do
    let(:topic) { Factory :topic }
    let(:admin) { Factory :admin }
    let(:user) { Factory :user }
    let(:user1) { Factory :user }
    let(:reply) { Factory :reply, :user => user, :topic => topic }
    let(:reply1) { Factory :reply, :user => user1, :topic => topic }
    
    it "should require login to destroy reply" do
      delete :destroy, :topic_id => topic.id, :id => reply.id
      response.should_not be_success
    end
    
    it "user1 should not allow destroy reply" do
      sign_in user1
      delete :destroy, :topic_id => topic.id, :id => reply.id
      response.should_not be_success
    end
      
    it "user should destroy reply with itself" do
      sign_in user
      delete :destroy, :topic_id => topic.id, :id => reply.id
      response.should redirect_to(topic_path(topic))
    end
    
    it "admin should destroy reply" do
      sign_in admin
      delete :destroy, :topic_id => topic.id, :id => reply.id
      response.should redirect_to(topic_path(topic))
      
      delete :destroy, :topic_id => topic.id, :id => reply1.id
      response.should redirect_to(topic_path(topic))
    end
  end
end
