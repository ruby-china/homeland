require 'spec_helper'

describe RubyChina::API, "topics" do
  describe "GET /api/topics.json" do
    it "should be ok" do
      get "/api/topics.json"
      response.status.should == 200
    end
  end

  describe "POST /api/topics.json" do
    it "should post a new topic" do
      node_id = Factory(:node)._id
      user = Factory(:user).tap { |u| u.update_private_token }
      post "/api/topics.json", :token => user.private_token, :title => "api create topic", :body => "here we go", :node_id => node_id
      response.status.should == 201

      user.reload.topics.first.title.should == "api create topic"
    end
  end
end
