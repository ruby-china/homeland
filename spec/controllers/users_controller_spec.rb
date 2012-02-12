require 'spec_helper'

describe UsersController do
  let(:user) { Factory :user }

  describe ":index" do
    it "should have an index action" do
      get :index
      response.should be_success
    end
  end

  describe ":show" do
    it "should show user" do
      get :show, :id => user.login
      response.should be_success
    end

    it "should render 404 if user not found" do
      get :show, :id => "chunk_norris"
      response.should_not be_success
      response.status.should == 404
    end
  end

  describe ":replies" do
    it "should show user replies" do
      get :replies, :id => user.login
      response.should be_success
    end

    it "should render 404 if user not found" do
      get :replies, :id => "chunk_norris"
      response.should_not be_success
      response.status.should == 404
    end
  end

  describe ":likes" do
    it "should show user liked stuffs" do
      get :likes, :id => user.login
      response.should be_success
    end

    it "should render 404 if user not found" do
      get :likes, :id => "chunk_norris"
      response.should_not be_success
      response.status.should == 404
    end
  end

  describe ":location" do
    it "should render 404 if there is no user in that location" do
      get :location, :id => "Mars"
      response.should_not be_success
      response.status.should == 404
    end

    it "should show user associated with that location" do
      get :location, :id => user.location
      response.should be_success
      assigns[:users].should include(user)
    end
  end
end
