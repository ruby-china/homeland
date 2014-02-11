require 'spec_helper'

describe RubyChina::API, "topics" do
  describe "GET /api/topics.json" do
    it "should be ok" do
      get "/api/topics.json"
      response.status.should == 200
    end

    it "should be ok for all types" do
      Factory(:topic, :title => "This is a normal topic", :replies_count => 1)
      Factory(:topic, :title => "This is an excellent topic", :excellent => 1, :replies_count => 1)
      Factory(:topic, :title => "This is a no_reply topic", :replies_count => 0)
      Factory(:topic, :title => "This is a popular topic", :replies_count => 1, :likes_count => 10)

      get "/api/v2/topics.json"
      response.status.should == 200
      json = JSON.parse(response.body)
      json.size.should == 4
      titles = json.map {|topic| topic["title"] }
      titles.should be_include("This is a normal topic")
      titles.should be_include("This is an excellent topic")
      titles.should be_include("This is a no_reply topic")
      titles.should be_include("This is a popular topic")

      get "/api/v2/topics.json", :type => 'excellent'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.size.should == 1
      json[0]["title"].should == "This is an excellent topic"

      get "/api/v2/topics.json", :type => 'no_reply'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.size.should == 1
      json[0]["title"].should == "This is a no_reply topic"

      get "/api/v2/topics.json", :type => 'popular'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.size.should == 1
      json[0]["title"].should == "This is a popular topic"

      get "/api/v2/topics.json", :type => 'recent'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.size.should == 4
      json[0]["title"].should == "This is a popular topic"
      json[1]["title"].should == "This is a no_reply topic"
      json[2]["title"].should == "This is an excellent topic"
      json[3]["title"].should == "This is a normal topic"
    end
  end

  describe "GET /api/topics/node/:id.json" do
    it "should return a list of topics that belong to the specified node" do
      node = Factory(:node)
      other_topics = [Factory(:topic), Factory(:topic)]

      topics = []
      topics << Factory(:topic, :node_id => node.id, :title => "This is a normal topic", :replies_count => 1)
      topics << Factory(:topic, :node_id => node.id, :title => "This is an excellent topic", :excellent => 1, :replies_count => 1)
      topics << Factory(:topic, :node_id => node.id, :title => "This is a no_reply topic", :replies_count => 0)
      topics << Factory(:topic, :node_id => node.id, :title => "This is a popular topic", :replies_count => 1, :likes_count => 10)

      get "/api/topics/node/#{node.id}.json"
      response.status.should == 200
      json = JSON.parse(response.body)
      json_titles = json.map { |t| t["id"] }
      topics.each { |t| json_titles.should include(t._id) }
      other_topics.each { |t| json_titles.should_not include(t._id) }

      get "/api/v2/topics/node/#{node.id}.json", :size => 2
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(2).items
      json[0]["title"].should == "This is a normal topic"
      json[1]["title"].should == "This is an excellent topic"

      get "/api/v2/topics/node/#{node.id}.json", :per_page => 2, :page => 1
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(2).items
      json[0]["title"].should == "This is a normal topic"
      json[1]["title"].should == "This is an excellent topic"

      get "/api/v2/topics/node/#{node.id}.json", :per_page => 2, :page => 2
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(2).items
      json[0]["title"].should == "This is a no_reply topic"
      json[1]["title"].should == "This is a popular topic"

      get "/api/v2/topics/node/#{node.id}.json", :type => 'excellent'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(1).item
      json[0]["title"].should == "This is an excellent topic"

      get "/api/v2/topics/node/#{node.id}.json", :type => 'no_reply'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(1).item
      json[0]["title"].should == "This is a no_reply topic"

      get "/api/v2/topics/node/#{node.id}.json", :type => 'popular'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(1).item
      json[0]["title"].should == "This is a popular topic"

      get "/api/v2/topics/node/#{node.id}.json", :type => 'recent'
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(4).items
      json[0]["title"].should == "This is a popular topic"
      json[1]["title"].should == "This is a no_reply topic"
      json[2]["title"].should == "This is an excellent topic"
      json[3]["title"].should == "This is a normal topic"
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
      Factory(:reply, :topic_id => t.id, :body => "let me tell")
      Factory(:reply, :topic_id => t.id, :body => "let me tell again", :deleted_at => Time.now)
      get "/api/topics/#{t.id}.json"
      response.status.should == 200
      json = JSON.parse(response.body)
      json["title"].should == "i want to know"
      json["replies"].first["body"].should == "let me tell"
      json["replies"].first["deleted_at"].should be_nil
      json["hits"].should == old_hits + 1

      get "/api/v2/topics/#{t.id}.json", :include_deleted => true
      response.status.should == 200
      json = JSON.parse(response.body)
      json["title"].should == "i want to know"
      json["replies"][0]["body"].should == "let me tell"
      json["replies"][0]["deleted_at"].should be_nil
      json["replies"][1]["body"].should == "let me tell again"
      json["replies"][1]["deleted_at"].should_not be_nil
      json["hits"].should == old_hits + 2
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
      response.body.should == 'true'
      t.reload.follower_ids.should include(user.id)
    end
  end
  
  describe "POST /api/topics/:id/unfollow.json" do
    it "should unfollow a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 2")
      post "/api/topics/#{t.id}/unfollow.json", :token => user.private_token
      response.status.should == 201      
      response.body.should == 'true'
      t.reload.follower_ids.should_not include(user.id)
    end
  end
 
  describe "POST /api/topics/:id/favorite.json" do
    it "should favorite a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 3")
      post "/api/topics/#{t.id}/favorite.json", :token => user.private_token
      response.status.should == 201      
      response.body.should == 'true'
      user.reload.favorite_topic_ids.should include(t.id)
    end
  end

  describe "POST /api/topics/:id/favorite.json" do
    it "should unfavorite a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 3")
      post "/api/topics/#{t.id}/favorite.json", :token => user.private_token, :type => 'unfavorite'
      response.status.should == 201      
      response.body.should == 'true'
      user.reload.favorite_topic_ids.should_not include(t.id)
    end
  end  
end
