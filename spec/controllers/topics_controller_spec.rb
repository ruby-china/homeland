require 'spec_helper'

describe TopicsController do
  describe "#show" do
    it "should clear user mention notification when show topic" do
      notification = Factory :notification_mention
      sign_in notification.user
      lambda do
        get :show, :id => notification.reply.topic
      end.should change(notification.user.notifications.unread, :count)
    end
  end

  describe "#reply" do
    it "should read topic after user reply topic" do
      user = Factory :user
      topic = Factory :topic
      Factory :reply, :topic => topic
      user.topic_read?(topic).should_not be_true
      sign_in user
      post :reply, :id => topic, :reply => {:body => 'content'}, :format => :js
      topic.reload
      user.topic_read?(topic).should be_true
    end
  end
end
