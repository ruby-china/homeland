require 'spec_helper'

describe TopicsController do
  render_views

  describe "#show" do
    it "should clear user mention notification when show topic" do
      notification = Factory :notification_mention
      sign_in notification.user
      lambda do
        get :show, :id => notification.reply.topic
      end.should change(notification.user.notifications.unread, :count)
    end

    context "user deletes her own account" do
      let(:reply) { Factory(:reply, :body => "i said something not good") }
      subject { response }
      before do
        reply.user.destroy
        get :show, :id => reply.topic
      end

      it { should be_success }

      it { should_not include("i said something not good") }

      it "should not hold the reply in results" do
        assigns(:replies).should_not include(reply)
      end
    end
  end

end
