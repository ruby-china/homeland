require 'spec_helper'

describe UsersController do
  let(:user) { Factory :user, :location => "Shanghai" }

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

  describe ":topics" do
    it "should show user topics" do
      get :topics, :id => user.login
      response.should be_success
    end

    it "should render 404 if user not found" do
      get :topics, :id => "chunk_norris"
      response.should_not be_success
      response.status.should == 404
    end
  end

  describe ":favorites" do
    it "should show user liked stuffs" do
      get :favorites, :id => user.login
      response.should be_success
    end

    it "should render 404 if user not found" do
      get :favorites, :id => "chunk_norris"
      response.should_not be_success
      response.status.should == 404
    end
  end
  
  describe ":notes" do
    it "should show user notes" do
      get :notes, :id => user.login
      response.should be_success
    end

    it "should render 404 if user not found" do
      get :notes, :id => "chunk_norris"
      response.should_not be_success
      response.status.should == 404
    end
    
    it "assigns @notes" do
      note_1 = Factory(:note, :publish => true,:user => user)
      note_2 = Factory(:note, :publish => false,:user => user)
      get :notes,:id => user.login
      assigns(:notes).should == [note_1]
    end
  end

  describe ":city" do
    it "should render 404 if there is no user in that city" do
      get :city, :id => "Mars"
      response.should_not be_success
      response.status.should == 404
    end

    it "should show user associated with that city" do
      get :city, :id => user.location
      response.status.should == 200
      assigns[:users].should include(user)
    end
  end
end
