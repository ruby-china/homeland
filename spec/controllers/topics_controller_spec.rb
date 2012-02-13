require 'spec_helper'

describe TopicsController do
  render_views
  let(:topic) { Factory :topic, :user => user }
  let(:user) { Factory :user }

  describe ":index" do
    it "should have an index action" do
      get :index
      response.should be_success
    end
  end

  describe ":feed" do
    it "should have a feed action" do
      get :feed
      response.should be_success
    end
  end

  describe ":recent" do
    it "should have a recent action" do
      get :recent
      response.should be_success
    end
  end

  describe ":node" do

    it "should have a node action" do
      get :node, :id => topic.id
      response.should be_success
    end
  end

  describe ":node_feed" do
    it "should have a node_feed action" do
      get :node_feed, :id => topic.id
      response.should be_success
    end
  end

  describe ":new" do
    describe "unauthenticated" do
      it "should not allow anonymous access" do
        get :new
        response.should_not be_success
      end
    end

    describe "authenticated" do
      it "should allow access from authenticated user" do
        sign_in user
        get :new
        response.should be_success
      end
    end
  end

  describe ":edit" do
    context "unauthenticated" do
      it "should not allow anonymous access" do
        get :edit, :id => topic.id
        response.should_not be_success
      end
    end

    context "authenticated" do
      context "own topic" do
        it "should allow access from authenticated user" do
          sign_in user
          get :edit, :id => topic.id
          response.should be_success
        end
      end

      context "other's topic" do
        it "should not allow edit other's topic" do
          other_user = Factory :user
          topic_of_other_user = Factory(:topic, :user => other_user)
          sign_in user
          get :edit, :id => topic_of_other_user.id
          response.should_not be_success
        end
      end
    end
  end

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
