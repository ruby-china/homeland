require 'rails_helper'

describe RubyChina::API, "users", :type => :request do
  describe "GET /api/users/:user.json" do
    it "should be ok" do
      get "/api/users.json"
      expect(response.status).to eq(200)
    end

    it "should get user details with list of topics" do
      user = Factory(:user, :name => "test user", :login => "test_user", :email_public => true)
      topics = (1..10).map {|n| Factory(:topic, :title => "new topic #{n}", :user_id => user.id) }
      Factory(:reply, :topic_id => topics.last.id, :body => "let me tell", :user_id => user.id)
      get "/api/v2/users/test_user.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq(user.name)
      expect(json["login"]).to eq(user.login)
      expect(json["email"]).to eq(user.email)
      expect(json["topics"].size).to eq(5)
      (6..10).reverse_each {|n| expect(json["topics"][10 - n]["title"]).to eq("new topic #{n}") }
      expect(json["topics"].first["replies_count"]).to eq(1)
      expect(json["topics"].first["last_reply_user_login"]).to eq(user.login)
    end
  end
end