require 'rails_helper'

describe 'API V3', 'notifications', type: :request do
  describe 'GET /api/notifications.json' do
    it 'must require token' do
      get '/api/v3/notifications.json'
      expect(response.status).to eq(401)
    end

    it 'should be ok' do
      login_user!
      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
    end

    it 'should get notification for a mention in a reply' do
      topic = Factory :topic, user: current_user
      reply = Factory :reply, topic: topic, user: current_user, body: 'Test to mention user'
      Factory :notification_mention, user: current_user, mentionable: reply
      login_user!
      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      expect(json['notifications'][0]['read']).to eq false
      expect(json['notifications'][0]['mention_type']).to eq 'Reply'
      expect(json['notifications'][0]['mention']['body_html']).to eq('<p>Test to mention user</p>')
      expect(json['notifications'][0]['mention']['topic_id']).to eq(topic.id)
      expect(json['notifications'][0]['actor']['login']).to eq(current_user.login)
    end

    it 'should get notification for a reply' do
      login_user!
      topic = Factory :topic, user: current_user
      reply = Factory :reply, topic: topic, user: current_user, body: 'Test to reply user'
      Factory :notification_topic_reply, user: current_user, reply: reply
      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'][0]['read']).to eq false
      expect(json['notifications'][0]['reply']['body_html']).to eq('<p>Test to reply user</p>')
      expect(json['notifications'][0]['reply']['topic_id']).to eq(topic.id)
      expect(json['notifications'][0]['actor']['login']).to eq(current_user.login)
    end

    it 'should get notification for a mention in a topic' do
      login_user!
      node = Factory :node
      topic = Factory :topic, user: current_user, node: node, title: 'Test to mention user in a topic'
      Factory :notification_mention, user: current_user, mentionable: topic
      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'][0]['read']).to eq false
      expect(json['notifications'][0]['mention_type']).to eq 'Topic'
      expect(json['notifications'][0]['mention']['title']).to eq('Test to mention user in a topic')
      expect(json['notifications'][0]['mention']['node_name']).to eq(node.name)
      expect(json['notifications'][0]['actor']['login']).to eq(current_user.login)
    end

    it 'should return a list of notifications of the current user' do
      login_user!
      topic = Factory :topic, user: current_user
      replies = (0...10).map { |i| Factory :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      (0...10).map { |i| Factory :notification_mention, user: current_user, mentionable: replies[i] }

      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'].size).to eq(10)
      json['notifications'].each_with_index { |item, i| item['mention']['body'] == replies[i].body }

      get '/api/v3/notifications.json', limit: 5
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'].size).to eq(5)
      json['notifications'].each_with_index { |item, i| item['mention']['body'] == replies[i].body }

      get '/api/v3/notifications.json', offset: 5, limit: 5
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'].size).to eq(5)
      json['notifications'].each_with_index { |item, i| item['mention']['body'] == replies[i + 5].body }
    end
  end

  describe 'POST /api/notifications/read.json' do
    it 'must require token' do
      post '/api/v3/notifications/read.json', ids: [1, 2]
      expect(response.status).to eq(401)
    end

    it 'should work' do
      login_user!
      topic = Factory :topic, user: current_user
      replies = (0...10).map { |i| Factory :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      (0...10).map { |i| Factory :notification_mention, user: current_user, mentionable: replies[i] }
      post '/api/v3/notifications/read.json', ids: current_user.notifications.pluck(:id)
      expect(response.status).to eq 201
      current_user.notifications.each do |item|
        expect(item.reload.read).to eq true
      end
    end
  end

  describe 'DELETE /api/notifications/all.json' do
    it 'must require token' do
      delete '/api/v3/notifications/all.json'
      expect(response.status).to eq(401)
    end

    it 'should delete all notifications of current user' do
      login_user!
      topic = Factory :topic, user: current_user
      replies = (0...10).map { |i| Factory :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      (0...10).map { |i| Factory :notification_mention, user: current_user, mentionable: replies[i] }

      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      expect(json['notifications'].size).to eq(10)

      delete '/api/v3/notifications/all.json'
      expect(response.status).to eq(200)

      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications']).to be_empty
    end
  end

  describe 'DELETE /api/notifications/:id.json' do
    it 'must require token' do
      delete '/api/v3/notifications/1.json'
      expect(response.status).to eq(401)
    end

    it 'should delete the specified notification of current user' do
      login_user!
      topic = Factory :topic, user: current_user
      replies = (0...10).map { |i| Factory :reply, topic: topic, user: current_user, body: "Test to mention user #{i}" }
      mentions = (0...10).map { |i| Factory :notification_mention, user: current_user, mentionable: replies[i] }

      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'].size).to eq(10)

      deleted_ids = mentions.map(&:id).select(&:odd?)

      deleted_ids.each do |i|
        delete "/api/v3/notifications/#{i}.json"
        expect(response.status).to eq(200)
      end

      get '/api/v3/notifications.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['notifications'].size).to eq(10 - deleted_ids.size)
      json['notifications'].map { |item| expect(deleted_ids).not_to include(item['id']) }
    end
  end
end
