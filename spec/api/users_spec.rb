require 'rails_helper'

describe "API V3", "users", :type => :request do
  describe "GET /api/users/:user.json" do
    it "should be ok" do
      get "/api/v3/users.json"
      expect(response.status).to eq(200)
    end

    it "should get user details with list of topics" do
      user = Factory(:user, :name => "test user", :login => "test_user", :email_public => true)
      topics = (1..10).map {|n| Factory(:topic, :title => "new topic #{n}", :user_id => user.id) }
      Factory(:reply, :topic_id => topics.last.id, :body => "let me tell", :user_id => user.id)
      get "/api/v3/users/test_user.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json).to include(*%W(id name login email avatar_url location company twitter github website bio tagline))
      expect(json["name"]).to eq(user.name)
      expect(json["login"]).to eq(user.login)
      expect(json["email"]).to eq(user.email)
    end
  end
end