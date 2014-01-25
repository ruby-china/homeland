require 'spec_helper'

describe RubyChina::API, "users" do
  describe "GET /api/users/:user.json" do
    it "should be ok" do
      get "/api/users.json"
      response.status.should == 200
    end

    it "should get user details with list of topics" do
      user = Factory(:user, :name => "test user", :login => "test_user", :email_public => true)
      topics = (1..10).map {|n| Factory(:topic, :title => "new topic #{n}", :user_id => user.id) }
      Factory(:reply, :topic_id => topics.last.id, :body => "let me tell", :user_id => user.id)
      get "/api/v2/users/test_user.json"
      response.status.should == 200
      json = JSON.parse(response.body)
      json["name"].should == user.name
      json["login"].should == user.login
      json["email"].should == user.email
      json["topics"].size.should == 5
      (6..10).reverse_each {|n| json["topics"][10 - n]["title"].should == "new topic #{n}" }
      json["topics"].first["replies_count"].should == 1
      json["topics"].first["last_reply_user_login"].should == user.login
    end
  end
end