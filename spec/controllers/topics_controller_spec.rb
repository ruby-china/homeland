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
      user = Factory :user
      topic = Factory :topic, :body => "@#{user.login}"
      Factory :reply, :body => "@#{user.login}", :topic => topic
      sign_in user
      lambda do
        get :show, :id => topic
      end.should change(user.notifications.unread, :count).by(-2)
    end

    context "when the topic has 11 replies, and 10 are shown per page" do
      let!(:user) { FactoryGirl.build_stubbed(:user) }
      let!(:topic) { FactoryGirl.create(:topic) }
      let!(:reply) { FactoryGirl.create_list(:reply, 11, :topic => topic) }

      before { sign_in user }

      it "should show the last page by default" do
        get :show, :id => topic
        assigns[:page].should eq(2)
      end
    end
  end

end
