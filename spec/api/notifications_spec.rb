require 'rails_helper'

describe RubyChina::API, "notifications", :type => :request do
  let(:user) { Factory(:user) }

  before(:each) do
    user.update_private_token
  end

  describe "GET /api/notifications.json" do
    it "must require token" do
      get "/api/v2/notifications.json"
      expect(response.status).to eq(401)
    end

    it "should be ok" do
      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
    end

    it "should get notification for a mention in a reply" do
      topic = Factory :topic, :user => user
      reply = Factory :reply, :topic => topic, :user => user, :body => "Test to mention user"
      mention = Factory :notification_mention, :user => user, :mentionable => reply
      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json[0]["read"]).to be_falsey
      expect(json[0]["mention"]["body"]).to eq("Test to mention user")
      expect(json[0]["mention"]["topic_id"]).to eq(topic.id)
      expect(json[0]["mention"]["user"]["login"]).to eq(user.login)
    end

    it "should get notification for a reply" do
      topic = Factory :topic, :user => user
      reply = Factory :reply, :topic => topic, :user => user, :body => "Test to reply user"
      notification = Factory :notification_topic_reply, :user => user, :reply => reply
      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json[0]["read"]).to be_falsey
      expect(json[0]["reply"]["body"]).to eq("Test to reply user")
      expect(json[0]["reply"]["topic_id"]).to eq(topic.id)
      expect(json[0]["reply"]["user"]["login"]).to eq(user.login)
    end

    it "should get notification for a mention in a topic" do
      node = Factory :node
      topic = Factory :topic, :user => user, :node => node, :title => "Test to mention user in a topic"
      mention = Factory :notification_mention, :user => user, :mentionable => topic
      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json[0]["read"]).to be_falsey
      expect(json[0]["mention"]["title"]).to eq("Test to mention user in a topic")
      expect(json[0]["mention"]["node_name"]).to eq(node.name)
      expect(json[0]["mention"]["user"]["login"]).to eq(user.login)
    end

    it "should return a list of notifications of the current user" do
      topic = Factory :topic, :user => user
      replies = (0...10).map {|i| Factory :reply, :topic => topic, :user => user, :body => "Test to mention user #{i}" }
      mentions = (0...10).map {|i| Factory :notification_mention, :user => user, :mentionable => replies[i] }

      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(10)
      json.each_with_index {|item, i| item["mention"]["body"] == replies[i].body }

      get "/api/v2/notifications.json", :token => user.private_token, :per_page => 5
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(5)
      json.each_with_index {|item, i| item["mention"]["body"] == replies[i].body }

      get "/api/v2/notifications.json", :token => user.private_token, :per_page => 5, :page => 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(5)
      json.each_with_index {|item, i| item["mention"]["body"] == replies[i + 5].body }
    end
  end

  describe "DELETE /api/notifications.json" do
    it "must require token" do
      delete "/api/v2/notifications.json"
      expect(response.status).to eq(401)
    end

    it "should delete all notifications of current user" do
      topic = Factory :topic, :user => user
      replies = (0...10).map {|i| Factory :reply, :topic => topic, :user => user, :body => "Test to mention user #{i}" }
      mentions = (0...10).map {|i| Factory :notification_mention, :user => user, :mentionable => replies[i] }

      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(10)

      delete "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      expect(response.body).to eq('true')

      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end
  end

  describe "DELETE /api/notifications/:id.json" do
    it "must require token" do
      delete "/api/v2/notifications/1.json"
      expect(response.status).to eq(401)
    end

    it "should delete the specified notification of current user" do
      topic = Factory :topic, :user => user
      replies = (0...10).map {|i| Factory :reply, :topic => topic, :user => user, :body => "Test to mention user #{i}" }
      mentions = (0...10).map {|i| Factory :notification_mention, :user => user, :mentionable => replies[i] }

      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(10)

      deleted_ids = mentions.map(&:id).select(&:odd?)

      deleted_ids.each do |i|
        delete "/api/v2/notifications/#{i}.json", :token => user.private_token
        expect(response.status).to eq(200)
        expect(response.body).to eq('true')
      end

      get "/api/v2/notifications.json", :token => user.private_token
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.size).to eq(10 - deleted_ids.size)
      json.map {|item| expect(deleted_ids).not_to include(item["id"]) }
    end
  end
end