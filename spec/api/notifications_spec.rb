require 'spec_helper'

describe RubyChina::API, "notifications" do
  let(:user) { Factory(:user) }

  before(:each) do
    user.update_private_token
  end

  describe "GET /api/notifications.json" do
    it "must require token" do
      get "/api/v2/notifications.json"
      response.status.should == 401
    end

    it "should be ok" do
      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
    end

    it "should get notification for a mention in a reply" do
      topic = Factory :topic, :user => user
      reply = Factory :reply, :topic => topic, :user => user, :body => "Test to mention user"
      mention = Factory :notification_mention, :user => user, :mentionable => reply
      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json[0]["read"].should be_false
      json[0]["mention"]["body"].should == "Test to mention user"
      json[0]["mention"]["topic_id"].should == topic.id
      json[0]["mention"]["user"]["login"].should == user.login
    end

    it "should get notification for a reply" do
      topic = Factory :topic, :user => user
      reply = Factory :reply, :topic => topic, :user => user, :body => "Test to reply user"
      notification = Factory :notification_topic_reply, :user => user, :reply => reply
      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json[0]["read"].should be_false
      json[0]["reply"]["body"].should == "Test to reply user"
      json[0]["reply"]["topic_id"].should == topic.id
      json[0]["reply"]["user"]["login"].should == user.login
    end

    it "should get notification for a mention in a topic" do
      node = Factory :node
      topic = Factory :topic, :user => user, :node => node, :title => "Test to mention user in a topic"
      mention = Factory :notification_mention, :user => user, :mentionable => topic
      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json[0]["read"].should be_false
      json[0]["mention"]["title"].should == "Test to mention user in a topic"
      json[0]["mention"]["node_name"].should == node.name
      json[0]["mention"]["user"]["login"].should == user.login
    end

    it "should return a list of notifications of the current user" do
      topic = Factory :topic, :user => user
      replies = (0...10).map {|i| Factory :reply, :topic => topic, :user => user, :body => "Test to mention user #{i}" }
      mentions = (0...10).map {|i| Factory :notification_mention, :user => user, :mentionable => replies[i] }

      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(10).items
      json.each_with_index {|item, i| item["mention"]["body"] == replies[i].body }

      get "/api/v2/notifications.json", :token => user.private_token, :per_page => 5
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(5).items
      json.each_with_index {|item, i| item["mention"]["body"] == replies[i].body }

      get "/api/v2/notifications.json", :token => user.private_token, :per_page => 5, :page => 2
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(5).items
      json.each_with_index {|item, i| item["mention"]["body"] == replies[i + 5].body }
    end
  end

  describe "DELETE /api/notifications.json" do
    it "must require token" do
      delete "/api/v2/notifications.json"
      response.status.should == 401
    end

    it "should delete all notifications of current user" do
      topic = Factory :topic, :user => user
      replies = (0...10).map {|i| Factory :reply, :topic => topic, :user => user, :body => "Test to mention user #{i}" }
      mentions = (0...10).map {|i| Factory :notification_mention, :user => user, :mentionable => replies[i] }

      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(10).items

      delete "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      response.body.should == 'true'

      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should be_empty
    end
  end

  describe "DELETE /api/notifications/:id.json" do
    it "must require token" do
      delete "/api/v2/notifications/1.json"
      response.status.should == 401
    end

    it "should delete the specified notification of current user" do
      topic = Factory :topic, :user => user
      replies = (0...10).map {|i| Factory :reply, :topic => topic, :user => user, :body => "Test to mention user #{i}" }
      mentions = (0...10).map {|i| Factory :notification_mention, :user => user, :mentionable => replies[i] }

      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(10).items

      deleted_ids = mentions.map(&:id).select(&:odd?)

      deleted_ids.each do |i|
        delete "/api/v2/notifications/#{i}.json", :token => user.private_token
        response.status.should == 200
        response.body.should == 'true'
      end

      get "/api/v2/notifications.json", :token => user.private_token
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should have(10 - deleted_ids.size).items
      json.map {|item| deleted_ids.should_not include(item["id"]) }
    end
  end
end