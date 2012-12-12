require 'spec_helper'

describe RubyChina::API, "topics" do
  describe "GET /api/topics.json" do
    it "should be ok" do
      get "/api/topics.json"
      response.status.should == 200
    end
  end

  describe "GET /api/topics/node/:id.json" do
    it "should return a list of topics that belong to the specified node" do
      node = Factory(:node)
      other_topics = [Factory(:topic), Factory(:topic)]
      topics = Array.new(2).map { Factory(:topic, :node_id => node.id) }

      get "/api/topics/node/#{node.id}.json"
      json = JSON.parse(response.body)
      json_titles = json.map { |t| t["id"] }
      topics.each { |t| json_titles.should include(t._id) }
      other_topics.each { |t| json_titles.should_not include(t._id) }
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

  describe "GET /api/topics/:id.json" do
    it "should get topic detail with list of replies" do
      t = Factory(:topic, :title => "i want to know")
      old_hits = t.hits.to_i
      r = Factory(:reply, :topic_id => t.id, :body => "let me tell")
      get "/api/topics/#{t.id}.json"
      response.status.should == 200
      json = JSON.parse(response.body)
      json["title"].should == "i want to know"
      json["replies"].first["body"].should == "let me tell"
      json["hits"].should == old_hits + 1
    end
  end
  
  describe "POST /api/topics/:id/replies.json" do
    it "should post a new reply" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 1")
      post "/api/topics/#{t.id}/replies.json", :token => user.private_token, :body => "new reply body"
      response.status.should == 201      
      t.reload.replies.first.body.should == "new reply body"
    end
  end
  
  describe "POST /api/topics/:id/follow.json" do
    it "should follow a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 2")
      post "/api/topics/#{t.id}/follow.json", :token => user.private_token
      response.status.should == 201      
      t.reload.follower_ids.should include(user.id)
    end
  end
  
  describe "POST /api/topics/:id/unfollow.json" do
    it "should unfollow a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 2")
      post "/api/topics/#{t.id}/unfollow.json", :token => user.private_token
      response.status.should == 201      
      t.reload.follower_ids.should_not include(user.id)
    end
  end
 
  describe "POST /api/topics/:id/favorite.json" do
    it "should favorite a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 3")
      post "/api/topics/#{t.id}/favorite.json", :token => user.private_token
      response.status.should == 201      
      user.reload.favorite_topic_ids.should include(t.id)
    end
  end

  describe "POST /api/topics/:id/favorite.json" do
    it "should unfavorite a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 3")
      post "/api/topics/#{t.id}/favorite.json", :token => user.private_token, :type => 'unfavorite'
      response.status.should == 201      
      user.reload.favorite_topic_ids.should_not include(t.id)
    end
  end  
end
