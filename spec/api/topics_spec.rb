require 'rails_helper'

describe "API V3", "topics", :type => :request do
  describe "GET /api/v3/topics.json" do
    it "should be ok" do
      get "/api/v3/topics.json"
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

      get "/api/v3/topics.json"
      expect(response.status).to eq(200)
      expect(json["topics"].size).to eq(4)
      expect(json["topics"][0]).to include(*%W(id title created_at updated_at replied_at 
      replies_count node_name node_id last_reply_user_id last_reply_user_login deleted))
      titles = json["topics"].map {|topic| topic["title"] }
      expect(titles).to be_include("This is a normal topic")
      expect(titles).to be_include("This is an excellent topic")
      expect(titles).to be_include("This is a no_reply topic")
      expect(titles).to be_include("This is a popular topic")

      get "/api/v3/topics.json", type: 'excellent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(1)
      expect(json["topics"][0]["title"]).to eq("This is an excellent topic")

      get "/api/v3/topics.json", type: 'no_reply'
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json["topics"].size).to eq(1)
      expect(json["topics"][0]["title"]).to eq("This is a no_reply topic")

      get "/api/v3/topics.json", type: 'popular'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(1)
      expect(json["topics"][0]["title"]).to eq("This is a popular topic")

      get "/api/v3/topics.json", type: 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(4)
      expect(json["topics"][0]["title"]).to eq("This is a popular topic")
      expect(json["topics"][1]["title"]).to eq("This is a no_reply topic")
      expect(json["topics"][2]["title"]).to eq("This is an excellent topic")
      expect(json["topics"][3]["title"]).to eq("This is a normal topic")
    end
    
    describe 'with logined user' do
      it 'should hide user blocked nodes/users' do
        user = Factory(:user)
        node = Factory(:node)
        t1 = Factory(:topic, user: user)
        t2 = Factory(:topic, node: node)
        t3 = Factory(:topic)
        current_user.block_user(user.id)
        current_user.block_node(node.id)
        login_user!
        get "/api/v3/topics.json"
        expect(json["topics"].size).to eq 1
        expect(json["topics"][0]["id"]).to eq t3.id
      end
    end
  end

  describe "GET /api/v3/topics.json with node_id" do
    let(:node) { Factory(:node) }
    let(:node1) { Factory(:node) }

    let(:t1) { Factory(:topic, :node_id => node.id, :title => "This is a normal topic", :replies_count => 1) }
    let(:t2) { Factory(:topic, :node_id => node.id, :title => "This is an excellent topic", :excellent => 1, :replies_count => 1) }
    let(:t3) { Factory(:topic, :node_id => node.id, :title => "This is a no_reply topic", :replies_count => 0) }
    let(:t4) { Factory(:topic, :node_id => node.id, :title => "This is a popular topic", :replies_count => 1, :likes_count => 10) }

    it "should return a list of topics that belong to the specified node" do
      other_topics = [Factory(:topic, node_id: node1.id), Factory(:topic, node_id: node1.id)]
      topics = [t1, t2, t3, t4]
      
      get "/api/v3/topics.json", node_id: -1
      expect(response.status).to eq(404)

      get "/api/v3/topics.json", node_id: node.id
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json["topics"].size).to eq 4
      json_titles = json["topics"].map { |t| t["id"] }
      topics.each { |t| expect(json_titles).to include(t.id) }
      other_topics.each { |t| expect(json_titles).not_to include(t.id) }

      get "/api/v3/topics.json", node_id: node.id, type: 'excellent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(1)
      expect(json["topics"][0]["title"]).to eq("This is an excellent topic")

      get "/api/v3/topics.json", node_id: node.id, type: 'no_reply'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(1)
      expect(json["topics"][0]["title"]).to eq("This is a no_reply topic")

      get "/api/v3/topics.json", node_id: node.id, type: 'popular'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(1)
      expect(json["topics"][0]["title"]).to eq("This is a popular topic")

      get "/api/v3/topics.json", node_id: node.id, type: 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(4)
      expect(json["topics"][0]["title"]).to eq("This is a popular topic")
      expect(json["topics"][1]["title"]).to eq("This is a no_reply topic")
      expect(json["topics"][2]["title"]).to eq("This is an excellent topic")
      expect(json["topics"][3]["title"]).to eq("This is a normal topic")

      t1.update(last_active_mark: 4)
      t2.update(last_active_mark: 3)
      t3.update(last_active_mark: 2)
      t4.update(last_active_mark: 1)

      get "/api/v3/topics.json", node_id: node.id, limit: 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(2)
      expect(json["topics"][0]["title"]).to eq("This is a normal topic")
      expect(json["topics"][1]["title"]).to eq("This is an excellent topic")

      get "/api/v3/topics.json", node_id: node.id, offset: 0, limit: 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(2)
      expect(json["topics"][0]["title"]).to eq("This is a normal topic")
      expect(json["topics"][1]["title"]).to eq("This is an excellent topic")

      get "/api/v3/topics.json", offset: 2, limit: 2, node_id: node.id
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json["topics"].size).to eq(2)
      expect(json["topics"][0]["title"]).to eq("This is a no_reply topic")
      expect(json["topics"][1]["title"]).to eq("This is a popular topic")
    end
  end

  describe "POST /api/v3/topics.json" do
    it 'should require user' do
      post "/api/v3/topics.json", :title => "api create topic", :body => "here we go", :node_id => 1
      expect(response.status).to eq 401
    end
    
    it "should post a new topic" do
      login_user!
      node_id = Factory(:node)._id
      post "/api/v3/topics.json", :title => "api create topic", :body => "here we go", :node_id => node_id
      expect(response.status).to eq(201)
      expect(json["topic"]["body_html"]).to eq "<p>here we go</p>"
      
      last_topic = current_user.reload.topics.first

      expect(last_topic.title).to eq("api create topic")
      expect(last_topic.node_id).to eq node_id
    end
  end
  
  describe "POST /api/v3/topics/:id.json" do
    let!(:topic) { Factory(:topic) }
    
    it 'should require user' do
      post "/api/v3/topics/#{topic.id}.json", :title => "api create topic", :body => "here we go", :node_id => 1
      expect(response.status).to eq 401
    end
    
    it 'should return 403 when topic owner is now current_user, and not admin' do
      login_user!
      post "/api/v3/topics/#{topic.id}.json", :title => "api create topic", :body => "here we go", :node_id => 1
      expect(response.status).to eq 403
    end
    
    it 'should update with admin user' do
      allow_any_instance_of(User).to receive(:admin?).and_return(true)
      new_node = Factory(:node)
      login_user!
      post "/api/v3/topics/#{topic.id}.json", :title => "api create topic", :body => "here we go", :node_id => new_node.id
      expect(response.status).to eq 201
      topic.reload
      expect(topic.lock_node).to eq true
    end
    
    context 'with user' do
      let!(:topic) { Factory(:topic, user: current_user) }
      
      it "should post a new topic" do
        login_user!
        node_id = Factory(:node)._id
        post "/api/v3/topics/#{topic.id}.json", :title => "api create topic", :body => "here we go", :node_id => node_id
        expect(response.status).to eq(201)
        expect(json["topic"]["body_html"]).to eq "<p>here we go</p>"
      
        last_topic = current_user.reload.topics.first

        expect(last_topic.title).to eq("api create topic")
        expect(last_topic.body).to eq "here we go"
        expect(last_topic.node_id).to eq node_id
      end
      
      it 'should node update node_id when topic is lock_node' do
        topic.update_attribute(:lock_node, true)
        login_user!
        node_id = Factory(:node)._id
        post "/api/v3/topics/#{topic.id}.json", :title => "api create topic", :body => "here we go", :node_id => node_id
        topic.reload
        expect(topic.node_id).not_to eq node_id
      end
    end    
  end

  describe "GET /api/v3/topics/:id.json" do
    it "should get topic detail with list of replies" do
      t = Factory(:topic, :title => "i want to know")
      old_hits = t.hits.to_i
      get "/api/v3/topics/#{t.id}.json"
      expect(response.status).to eq(200)
      expect(json["topic"]).to include(*%W(id title created_at updated_at replied_at body body_html
      replies_count node_name node_id last_reply_user_id last_reply_user_login deleted user))
      expect(json["topic"]["title"]).to eq("i want to know")
      expect(json["topic"]["hits"]).to eq(old_hits + 1)
      expect(json["topic"]["user"]).to include(*%W(id name login avatar_url))
    end

    it "should work when id record found" do
      get "/api/v3/topics/-1.json"
      expect(response.status).to eq(404)
    end
  end
  
  describe 'GET /api/v3/topic/:id/replies.json' do
    it 'should work' do
      login_user!
      t = Factory(:topic, :title => "i want to know")
      r1 = Factory(:reply, :topic_id => t.id, :body => "let me tell")
      r2 = Factory(:reply, :topic_id => t.id, :body => "let me tell again", :deleted_at => Time.now)
      get "/api/v3/topics/#{t.id}/replies.json"
      expect(response.status).to eq(200)
      expect(json["replies"].size).to eq 2
      expect(json["replies"][0]).to include(*%W(id user body body_html created_at updated_at deleted))
      expect(json["replies"][0]["user"]).to include(*%W(id name login avatar_url))
      expect(json["replies"][0]["id"]).to eq r1.id
      expect(json["replies"][1]["id"]).to eq r2.id
    end
  end

  describe "POST /api/v3/topics/:id/replies.json" do
    it "should post a new reply" do
      login_user!
      t = Factory(:topic, :title => "new topic 1")
      post "/api/v3/topics/#{t.id}/replies.json", :body => "new reply body"
      expect(response.status).to eq(201)
      expect(t.reload.replies.first.body).to eq("new reply body")
    end
  end

  describe "POST /api/v3/topics/:id/follow.json" do
    it "should follow a topic" do
      login_user!
      t = Factory(:topic, :title => "new topic 2")
      post "/api/v3/topics/#{t.id}/follow.json"
      expect(response.status).to eq(201)
      expect(t.reload.follower_ids).to include(current_user.id)
    end
  end

  describe "POST /api/v3/topics/:id/unfollow.json" do
    it "should unfollow a topic" do
      login_user!
      t = Factory(:topic, :title => "new topic 2")
      post "/api/v3/topics/#{t.id}/unfollow.json"
      expect(response.status).to eq(201)
      expect(t.reload.follower_ids).not_to include(current_user.id)
    end
  end

  describe "POST /api/v3/topics/:id/favorite.json" do
    it "should favorite a topic" do
      login_user!
      t = Factory(:topic, :title => "new topic 3")
      post "/api/v3/topics/#{t.id}/favorite.json"
      expect(response.status).to eq(201)
      expect(current_user.reload.favorite_topic_ids).to include(t.id)
    end
  end

  describe "POST /api/v3/topics/:id/unfavorite.json" do
    it "should unfavorite a topic" do
      login_user!
      t = Factory(:topic, :title => "new topic 3")
      post "/api/v3/topics/#{t.id}/unfavorite.json"
      expect(response.status).to eq(201)
      expect(current_user.reload.favorite_topic_ids).not_to include(t.id)
    end
  end
end
