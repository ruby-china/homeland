# coding: utf-8
require 'spec_helper'

describe LikesController do
  let(:user) { Factory(:user) }
  let(:user2) { Factory(:user) }
  let(:topic) { Factory(:topic) }

  before(:each) do
    controller.stub(:current_user).and_return(user)
  end

  it "POST /likes" do
    post :create, :type => "Topic", :id => topic.id
    response.body.should == "1"
    topic.reload.likes_count.should == 1

    post :create, :type => "Topic", :id => topic.id
    response.body.should == "1"
    topic.reload.likes_count.should == 1

    controller.stub(:current_user).and_return(user2)
    post :create, :type => "Topic", :id => topic.id
    response.body.should == "2"
    topic.reload.likes_count.should == 2

    controller.stub(:current_user).and_return(user)
    delete :destroy, :type => "Topic", :id => topic.id
    response.body.should == "1"
    topic.reload.likes_count.should == 1

    controller.stub(:current_user).and_return(user2)
    delete :destroy, :type => "Topic", :id => topic.id
    response.body.should == "0"
    topic.reload.likes_count.should == 0
  end

  it "require login" do
    controller.stub(:current_user).and_return(nil)
    post :create
    response.status.should == 302

    delete :destroy
    response.status.should == 302
  end

  it "result -1, -2 when params is wrong" do
    post :create, :type => "Ask", :id => 1
    response.body.should == "-1"

    delete :destroy, :type => "Ask", :id => 1
    response.body.should == "-1"

    post :create, :type => "Topic", :id => -1
    response.body.should == "-2"

    delete :destroy, :type => "Topic", :id => -1
    response.body.should == "-2"
  end
end
