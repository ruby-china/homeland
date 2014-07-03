require 'rails_helper'

describe NotificationsController, :type => :controller do
  let(:user) { Factory :user }
  describe "#index" do
    it "should show notifications" do
      sign_in user
      Factory :notification_mention, :user => user, :mentionable => Factory(:reply)
      Factory :notification_topic_reply, :user => user
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "#destroy" do
    it "should destroy notification" do
      sign_in user
      notification = Factory :notification_mention, :user => user, :mentionable => Factory(:reply)

      expect do
        delete :destroy, :id => notification
      end.to change(user.notifications, :count)
    end
  end

  describe "#clear" do
    it "should clear all" do
      sign_in user
      3.times{ Factory :notification_mention, :user => user, :mentionable => Factory(:reply) }

      post :clear
      expect(user.notifications.unread.count).to eq(0)
    end
  end
end
