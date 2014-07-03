require 'rails_helper'

describe RubyChina::API, "topics", :type => :request do
  describe "GET /api/topics.json" do
    it "should be ok" do
      get "/api/topics.json"
      expect(response.status).to eq(200)
    end

    it "should be ok for all types" do
      Factory(:topic, :title => "This is a normal topic", :replies_count => 1)
      Factory(:topic, :title => "This is an excellent topic", :excellent => 1, :replies_count => 1)
      Factory(:topic, :title => "This is a no_reply topic", :replies_count => 0)
      Factory(:topic, :title => "This is a popular topic", :replies_count => 1, :likes_count => 10)

      node = Factory(:node, :name => 'No Point')
      Factory(:topic, :title => 'This is a No Point topic', :node => node)
      SiteConfig.node_ids_hide_in_topics_index = node.id.to_s

      get "/api/v2/topics.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(4)
      titles = json.map {|topic| topic["title"] }
      expect(titles).to be_include("This is a normal topic")
      expect(titles).to be_include("This is an excellent topic")
      expect(titles).to be_include("This is a no_reply topic")
      expect(titles).to be_include("This is a popular topic")

      get "/api/v2/topics.json", :type => 'excellent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["title"]).to eq("This is an excellent topic")

      get "/api/v2/topics.json", :type => 'no_reply'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["title"]).to eq("This is a no_reply topic")

      get "/api/v2/topics.json", :type => 'popular'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["title"]).to eq("This is a popular topic")

      get "/api/v2/topics.json", :type => 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(4)
      expect(json[0]["title"]).to eq("This is a popular topic")
      expect(json[1]["title"]).to eq("This is a no_reply topic")
      expect(json[2]["title"]).to eq("This is an excellent topic")
      expect(json[3]["title"]).to eq("This is a normal topic")
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
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      json_titles = json.map { |t| t["id"] }
      topics.each { |t| expect(json_titles).to include(t._id) }
      other_topics.each { |t| expect(json_titles).not_to include(t._id) }

      get "/api/v2/topics/node/#{node.id}.json", :size => 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json[0]["title"]).to eq("This is a normal topic")
      expect(json[1]["title"]).to eq("This is an excellent topic")

      get "/api/v2/topics/node/#{node.id}.json", :per_page => 2, :page => 1
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json[0]["title"]).to eq("This is a normal topic")
      expect(json[1]["title"]).to eq("This is an excellent topic")

      get "/api/v2/topics/node/#{node.id}.json", :per_page => 2, :page => 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json[0]["title"]).to eq("This is a no_reply topic")
      expect(json[1]["title"]).to eq("This is a popular topic")

      get "/api/v2/topics/node/#{node.id}.json", :type => 'excellent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["title"]).to eq("This is an excellent topic")

      get "/api/v2/topics/node/#{node.id}.json", :type => 'no_reply'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["title"]).to eq("This is a no_reply topic")

      get "/api/v2/topics/node/#{node.id}.json", :type => 'popular'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]["title"]).to eq("This is a popular topic")

      get "/api/v2/topics/node/#{node.id}.json", :type => 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(4)
      expect(json[0]["title"]).to eq("This is a popular topic")
      expect(json[1]["title"]).to eq("This is a no_reply topic")
      expect(json[2]["title"]).to eq("This is an excellent topic")
      expect(json[3]["title"]).to eq("This is a normal topic")
    end
  end

  describe "POST /api/topics.json" do
    it "should post a new topic" do
      node_id = Factory(:node)._id
      user = Factory(:user).tap { |u| u.update_private_token }
      post "/api/topics.json", :token => user.private_token, :title => "api create topic", :body => "here we go", :node_id => node_id
      expect(response.status).to eq(201)

      expect(user.reload.topics.first.title).to eq("api create topic")
    end
  end

  describe "GET /api/topics/:id.json" do
    it "should get topic detail with list of replies" do
      t = Factory(:topic, :title => "i want to know")
      old_hits = t.hits.to_i
      Factory(:reply, :topic_id => t.id, :body => "let me tell")
      Factory(:reply, :topic_id => t.id, :body => "let me tell again", :deleted_at => Time.now)
      get "/api/topics/#{t.id}.json"
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("i want to know")
      expect(json["replies"].first["body"]).to eq("let me tell")
      expect(json["replies"].first["deleted_at"]).to be_nil
      expect(json["hits"]).to eq(old_hits + 1)

      get "/api/v2/topics/#{t.id}.json", :include_deleted => true
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("i want to know")
      expect(json["replies"][0]["body"]).to eq("let me tell")
      expect(json["replies"][0]["deleted_at"]).to be_nil
      expect(json["replies"][1]["body"]).to eq("let me tell again")
      expect(json["replies"][1]["deleted_at"]).not_to be_nil
      expect(json["hits"]).to eq(old_hits + 2)
    end
    
    it "should work when id record found" do
      get "/api/topics/-1.json"
      expect(response.status).to eq(404)
    end
  end
  
  describe "POST /api/topics/:id/replies.json" do
    it "should post a new reply" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 1")
      post "/api/topics/#{t.id}/replies.json", :token => user.private_token, :body => "new reply body"
      expect(response.status).to eq(201)      
      expect(t.reload.replies.first.body).to eq("new reply body")
    end
  end
  
  describe "POST /api/topics/:id/follow.json" do
    it "should follow a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 2")
      post "/api/topics/#{t.id}/follow.json", :token => user.private_token
      expect(response.status).to eq(201)      
      expect(response.body).to eq('true')
      expect(t.reload.follower_ids).to include(user.id)
    end
  end
  
  describe "POST /api/topics/:id/unfollow.json" do
    it "should unfollow a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 2")
      post "/api/topics/#{t.id}/unfollow.json", :token => user.private_token
      expect(response.status).to eq(201)      
      expect(response.body).to eq('true')
      expect(t.reload.follower_ids).not_to include(user.id)
    end
  end
 
  describe "POST /api/topics/:id/favorite.json" do
    it "should favorite a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 3")
      post "/api/topics/#{t.id}/favorite.json", :token => user.private_token
      expect(response.status).to eq(201)      
      expect(response.body).to eq('true')
      expect(user.reload.favorite_topic_ids).to include(t.id)
    end
  end

  describe "POST /api/topics/:id/favorite.json" do
    it "should unfavorite a topic" do
      user = Factory(:user).tap { |u| u.update_private_token }
      t = Factory(:topic, :title => "new topic 3")
      post "/api/topics/#{t.id}/favorite.json", :token => user.private_token, :type => 'unfavorite'
      expect(response.status).to eq(201)      
      expect(response.body).to eq('true')
      expect(user.reload.favorite_topic_ids).not_to include(t.id)
    end
  end  
end
