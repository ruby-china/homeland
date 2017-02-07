require 'rails_helper'

describe 'API V3', 'topics', type: :request do
  describe 'GET /api/v3/topics.json' do
    it 'should be ok' do
      get '/api/v3/topics.json'
      expect(response.status).to eq(200)
    end

    it 'should be ok for all types' do
      create(:topic, title: 'This is a normal topic', replies_count: 1)
      create(:topic, title: 'This is an excellent topic', excellent: 1, replies_count: 1)
      create(:topic, title: 'This is a no_reply topic', replies_count: 0)
      create(:topic, title: 'This is a popular topic', replies_count: 1, likes_count: 10)

      node = create(:node, name: 'No Point')
      create(:topic, title: 'This is a No Point topic', node: node)
      Setting.node_ids_hide_in_topics_index = node.id.to_s

      get '/api/v3/topics.json'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(4)
      fields = %w(id title created_at updated_at replied_at
                  replies_count node_name node_id last_reply_user_id
                  last_reply_user_login deleted excellent likes_count)
      expect(json['topics'][0]).to include(*fields)
      titles = json['topics'].map { |topic| topic['title'] }
      expect(titles).to be_include('This is a normal topic')
      expect(titles).to be_include('This is an excellent topic')
      expect(titles).to be_include('This is a no_reply topic')
      expect(titles).to be_include('This is a popular topic')

      get '/api/v3/topics.json', type: 'invalid_type'
      expect(response.status).to eq(200)
      json2 = JSON.parse(response.body)
      expect(json2).to eq(json)

      get '/api/v3/topics.json', type: 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(4)
      expect(json['topics'][0]['title']).to eq('This is a popular topic')
      expect(json['topics'][1]['title']).to eq('This is a no_reply topic')

      get '/api/v3/topics.json', type: 'excellent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(1)
      expect(json['topics'][0]['title']).to eq('This is an excellent topic')

      get '/api/v3/topics.json', type: 'no_reply'
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json['topics'].size).to eq(1)
      expect(json['topics'][0]['title']).to eq('This is a no_reply topic')

      get '/api/v3/topics.json', type: 'popular'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(1)
      expect(json['topics'][0]['title']).to eq('This is a popular topic')

      get '/api/v3/topics.json', type: 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(4)
      expect(json['topics'][0]['title']).to eq('This is a popular topic')
      expect(json['topics'][1]['title']).to eq('This is a no_reply topic')
      expect(json['topics'][2]['title']).to eq('This is an excellent topic')
      expect(json['topics'][3]['title']).to eq('This is a normal topic')
    end

    describe 'with logined user' do
      it 'should hide user blocked nodes/users' do
        user = create(:user)
        node = create(:node)
        create(:topic, user: user)
        create(:topic, node: node)
        t3 = create(:topic)
        current_user.block_user(user.id)
        current_user.block_node(node.id)
        login_user!
        get '/api/v3/topics.json'
        expect(json['topics'].size).to eq 1
        expect(json['topics'][0]['id']).to eq t3.id
      end
    end
  end

  describe 'GET /api/v3/topics.json with node_id' do
    let(:node) { create(:node) }
    let(:node1) { create(:node) }

    let(:t1) { create(:topic, node_id: node.id, title: 'This is a normal topic', replies_count: 1) }
    let(:t2) { create(:topic, node_id: node.id, title: 'This is an excellent topic', excellent: 1, replies_count: 1) }
    let(:t3) { create(:topic, node_id: node.id, title: 'This is a no_reply topic', replies_count: 0) }
    let(:t4) { create(:topic, node_id: node.id, title: 'This is a popular topic', replies_count: 1, likes_count: 10) }

    it 'should return a list of topics that belong to the specified node' do
      other_topics = [create(:topic, node_id: node1.id), create(:topic, node_id: node1.id)]
      topics = [t1, t2, t3, t4]

      get '/api/v3/topics.json', node_id: -1
      expect(response.status).to eq(404)

      get '/api/v3/topics.json', node_id: node.id
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json['topics'].size).to eq 4
      json_titles = json['topics'].map { |t| t['id'] }
      topics.each { |t| expect(json_titles).to include(t.id) }
      other_topics.each { |t| expect(json_titles).not_to include(t.id) }

      get '/api/v3/topics.json', node_id: node.id, type: 'excellent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(1)
      expect(json['topics'][0]['title']).to eq('This is an excellent topic')

      get '/api/v3/topics.json', node_id: node.id, type: 'no_reply'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(1)
      expect(json['topics'][0]['title']).to eq('This is a no_reply topic')

      get '/api/v3/topics.json', node_id: node.id, type: 'popular'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(1)
      expect(json['topics'][0]['title']).to eq('This is a popular topic')

      get '/api/v3/topics.json', node_id: node.id, type: 'recent'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(4)
      expect(json['topics'][0]['title']).to eq('This is a popular topic')
      expect(json['topics'][1]['title']).to eq('This is a no_reply topic')
      expect(json['topics'][2]['title']).to eq('This is an excellent topic')
      expect(json['topics'][3]['title']).to eq('This is a normal topic')

      t1.update(last_active_mark: 4)
      t2.update(last_active_mark: 3)
      t3.update(last_active_mark: 2)
      t4.update(last_active_mark: 1)

      get '/api/v3/topics.json', node_id: node.id, limit: 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(2)
      expect(json['topics'][0]['title']).to eq('This is a normal topic')
      expect(json['topics'][1]['title']).to eq('This is an excellent topic')

      get '/api/v3/topics.json', node_id: node.id, offset: 0, limit: 2
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(2)
      expect(json['topics'][0]['title']).to eq('This is a normal topic')
      expect(json['topics'][1]['title']).to eq('This is an excellent topic')

      get '/api/v3/topics.json', offset: 2, limit: 2, node_id: node.id
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['topics'].size).to eq(2)
      expect(json['topics'][0]['title']).to eq('This is a no_reply topic')
      expect(json['topics'][1]['title']).to eq('This is a popular topic')
    end
  end

  describe 'POST /api/v3/topics.json' do
    it 'should require user' do
      post '/api/v3/topics.json', title: 'api create topic', body: 'here we go', node_id: 1
      expect(response.status).to eq 401
    end

    it 'should work' do
      login_user!
      node_id = create(:node).id
      post '/api/v3/topics.json', title: 'api create topic', body: 'here we go', node_id: node_id
      expect(response.status).to eq(200)
      expect(json['topic']['body_html']).to eq '<p>here we go</p>'

      last_topic = current_user.reload.topics.first

      expect(last_topic.title).to eq('api create topic')
      expect(last_topic.node_id).to eq node_id
    end
  end

  describe 'POST /api/v3/topics/:id.json' do
    let!(:topic) { create(:topic) }

    it 'should require user' do
      post "/api/v3/topics/#{topic.id}.json", title: 'api create topic', body: 'here we go', node_id: 1
      expect(response.status).to eq 401
    end

    it 'should return 403 when topic owner is now current_user, and not admin' do
      login_user!
      post "/api/v3/topics/#{topic.id}.json", title: 'api create topic', body: 'here we go', node_id: 1
      expect(response.status).to eq 403
    end

    it 'should update with admin user' do
      new_node = create(:node)
      login_admin!
      post "/api/v3/topics/#{topic.id}.json", title: 'api create topic', body: 'here we go', node_id: new_node.id
      expect(response.status).to eq 200
      topic.reload
      expect(topic.lock_node).to eq true
    end

    context 'with user' do
      let!(:topic) { create(:topic, user: current_user) }

      it 'should work' do
        login_user!
        node_id = create(:node).id
        post "/api/v3/topics/#{topic.id}.json", title: 'api create topic', body: 'here we go', node_id: node_id
        expect(response.status).to eq(200)
        expect(json['topic']['body_html']).to eq '<p>here we go</p>'

        last_topic = current_user.reload.topics.first

        expect(last_topic.title).to eq('api create topic')
        expect(last_topic.body).to eq 'here we go'
        expect(last_topic.node_id).to eq node_id
      end

      it 'should node update node_id when topic is lock_node' do
        topic.update_attribute(:lock_node, true)
        login_user!
        node_id = create(:node).id
        post "/api/v3/topics/#{topic.id}.json", title: 'api create topic', body: 'here we go', node_id: node_id
        topic.reload
        expect(topic.node_id).not_to eq node_id
      end
    end
  end

  describe 'DELETE /api/v3/topics/:id.json' do
    let!(:topic) { create(:topic) }

    it 'should require user' do
      delete "/api/v3/topics/#{topic.id}.json"
      expect(response.status).to eq 401
    end

    it 'should return 404 when topic not found' do
      login_user!
      delete '/api/v3/topics/abc.json'
      expect(response.status).to eq 404
    end

    it 'should return 403 when topic owner is now current_user, and not admin' do
      login_user!
      delete "/api/v3/topics/#{topic.id}.json"
      expect(response.status).to eq 403
    end

    it 'should destroy with topic owner user' do
      login_user!
      topic = create(:topic, user: current_user)
      delete "/api/v3/topics/#{topic.id}.json"
      expect(response.status).to eq 200
      topic.reload
      expect(topic.deleted?).to eq true
    end

    it 'should destroy with admin user' do
      login_admin!
      delete "/api/v3/topics/#{topic.id}.json"
      expect(response.status).to eq 200
      topic.reload
      expect(topic.deleted?).to eq true
    end
  end

  describe 'GET /api/v3/topics/:id.json' do
    it 'should get topic detail with list of replies' do
      t = create(:topic, title: 'i want to know')
      old_hits = t.hits.to_i
      get "/api/v3/topics/#{t.id}.json"
      expect(response.status).to eq(200)
      fields = %w(id title created_at updated_at replied_at body body_html
                  replies_count node_name node_id last_reply_user_id
                  last_reply_user_login deleted user likes_count suggested_at closed_at)
      expect(json['topic']).to include(*fields)
      expect(json['meta']).to include(*%w(liked favorited followed))
      expect(json['topic']['title']).to eq('i want to know')
      expect(json['topic']['hits']).to eq(old_hits + 1)
      expect(json['topic']['user']).to include(*%w(id name login avatar_url))
      expect(json['topic']['abilities']).to include(*%w(update destroy))
      expect(json['topic']['abilities']['update']).to eq false
      expect(json['topic']['abilities']['destroy']).to eq false
      expect(json['topic']['abilities']['ban']).to eq false
      expect(json['topic']['abilities']['excellent']).to eq false
      expect(json['topic']['abilities']['unexcellent']).to eq false
      expect(json['topic']['abilities']['close']).to eq false
      expect(json['topic']['abilities']['open']).to eq false
    end

    it 'should return right abilities when owner visit' do
      t = create(:topic, user: current_user)
      login_user!
      get "/api/v3/topics/#{t.id}.json"
      expect(response.status).to eq(200)
      expect(json['topic']['abilities']['update']).to eq true
      expect(json['topic']['abilities']['destroy']).to eq true
      expect(json['topic']['abilities']['close']).to eq true
      expect(json['topic']['abilities']['open']).to eq true
    end

    it 'should return right abilities when admin visit' do
      t = create(:topic)
      login_admin!
      get "/api/v3/topics/#{t.id}.json"
      expect(response.status).to eq(200)
      expect(json['topic']['abilities']['update']).to eq true
      expect(json['topic']['abilities']['destroy']).to eq true
      expect(json['topic']['abilities']['close']).to eq true
      expect(json['topic']['abilities']['open']).to eq true
      expect(json['topic']['abilities']['ban']).to eq true
      expect(json['topic']['abilities']['excellent']).to eq true
      expect(json['topic']['abilities']['unexcellent']).to eq true
    end

    it 'should work when id record found' do
      get '/api/v3/topics/-1.json'
      expect(response.status).to eq(404)
    end

    context 'liked, followed, favorited' do
      let(:topic) { create(:topic) }

      it 'should work' do
        login_user!
        current_user.like(topic)
        current_user.favorite_topic(topic.id)
        get "/api/v3/topics/#{topic.id}.json"
        expect(response.status).to eq(200)
        expect(json['meta']).to include(*%w(liked favorited followed))
        expect(json['meta']['liked']).to eq true
        expect(json['meta']['favorited']).to eq true
        expect(json['meta']['followed']).to eq false
      end
    end
  end

  describe 'GET /api/v3/topic/:id/replies.json' do
    context 'no login' do
      it 'should work' do
        t = create(:topic, title: 'i want to know')
        create(:reply, topic_id: t.id, body: 'let me tell', user: current_user)
        create(:reply, topic_id: t.id, body: 'let me tell again', deleted_at: Time.now)
        get "/api/v3/topics/#{t.id}/replies.json"
        expect(response.status).to eq(200)
        expect(json['replies'].size).to eq 2
        expect(json['meta']['user_liked_reply_ids']).to eq([])
      end
    end

    context 'has login' do
      it 'should work' do
        login_user!
        t = create(:topic, title: 'i want to know')
        r1 = create(:reply, topic_id: t.id, body: 'let me tell', user: current_user)
        r2 = create(:reply, topic_id: t.id, body: 'let me tell again', deleted_at: Time.now)
        r3 = create(:reply, topic_id: t.id, body: 'let me tell again again')
        current_user.like(r2)
        current_user.like(r3)
        get "/api/v3/topics/#{t.id}/replies.json"
        expect(response.status).to eq(200)
        expect(json['replies'].size).to eq 3
        expect(json['replies'][0]).to include(*%w(id user body_html created_at updated_at deleted))
        expect(json['replies'][0]['user']).to include(*%w(id name login avatar_url))
        expect(json['replies'][0]['id']).to eq r1.id
        expect(json['replies'][0]['abilities']).to include(*%w(update destroy))
        expect(json['replies'][0]['abilities']['update']).to eq true
        expect(json['replies'][0]['abilities']['destroy']).to eq true
        expect(json['replies'][1]['id']).to eq r2.id
        expect(json['replies'][1]['deleted']).to eq true
        expect(json['replies'][1]['abilities']['update']).to eq false
        expect(json['replies'][1]['abilities']['destroy']).to eq false
        expect(json['meta']['user_liked_reply_ids']).to eq([r3.id])
      end
    end

    context 'admin login' do
      it 'should return right abilities when admin visit' do
        login_admin!
        t = create(:topic, title: 'i want to know')
        create(:reply, topic_id: t.id, body: 'let me tell')
        create(:reply, topic_id: t.id, body: 'let me tell again', deleted_at: Time.now)
        get "/api/v3/topics/#{t.id}/replies.json"
        expect(response.status).to eq(200)
        expect(json['replies'][0]['abilities']['update']).to eq true
        expect(json['replies'][0]['abilities']['destroy']).to eq true
        expect(json['replies'][1]['abilities']['update']).to eq true
        expect(json['replies'][1]['abilities']['destroy']).to eq true
      end
    end
  end

  describe 'POST /api/v3/topics/:id/replies.json' do
    it 'should post a new reply' do
      login_user!
      t = create(:topic, title: 'new topic 1')
      post "/api/v3/topics/#{t.id}/replies.json", body: 'new reply body'
      expect(response.status).to eq(200)
      expect(t.reload.replies.first.body).to eq('new reply body')
    end

    it 'should not create Reply when Topic was closed' do
      login_user!
      t = create(:topic, title: 'new topic 1', closed_at: Time.now)
      post "/api/v3/topics/#{t.id}/replies.json", body: 'new reply body'
      expect(response.status).to eq(400)
      expect(json['message']).to include('已关闭，不再接受回帖')
      expect(t.reload.replies.first).to eq nil
    end
  end

  describe 'POST /api/v3/topics/:id/follow.json' do
    it 'should follow a topic' do
      login_user!
      t = create(:topic, title: 'new topic 2')
      post "/api/v3/topics/#{t.id}/follow.json"
      expect(response.status).to eq(200)
      expect(t.reload.follow_by_user_ids).to include(current_user.id)
    end
  end

  describe 'POST /api/v3/topics/:id/unfollow.json' do
    it 'should unfollow a topic' do
      login_user!
      t = create(:topic, title: 'new topic 2')
      post "/api/v3/topics/#{t.id}/unfollow.json"
      expect(response.status).to eq(200)
      expect(t.reload.follow_by_user_ids).not_to include(current_user.id)
    end
  end

  describe 'POST /api/v3/topics/:id/favorite.json' do
    it 'should favorite a topic' do
      login_user!
      t = create(:topic, title: 'new topic 3')
      post "/api/v3/topics/#{t.id}/favorite.json"
      expect(response.status).to eq(200)
      expect(current_user.reload.favorite_topic_ids).to include(t.id)
    end
  end

  describe 'POST /api/v3/topics/:id/unfavorite.json' do
    it 'should unfavorite a topic' do
      login_user!
      t = create(:topic, title: 'new topic 3')
      post "/api/v3/topics/#{t.id}/unfavorite.json"
      expect(response.status).to eq(200)
      expect(current_user.reload.favorite_topic_ids).not_to include(t.id)
    end
  end

  describe 'POST /api/v3/topics/:id/ban.json' do
    it 'should work with admin' do
      login_admin!
      t = create(:topic, user: current_user, title: 'new topic 3')
      post "/api/v3/topics/#{t.id}/ban.json"
      expect(response.status).to eq(200)
    end

    it 'should not ban a topic with normal user' do
      login_user!
      t = create(:topic, title: 'new topic 3')
      post "/api/v3/topics/#{t.id}/ban.json"
      expect(response.status).to eq(403)

      t = create(:topic, user: current_user, title: 'new topic 3')
      post "/api/v3/topics/#{t.id}/ban.json"
      expect(response.status).to eq(403)
    end
  end

  describe 'POST /api/v3/topics/:id/action.json' do
    %w(excellent unexcellent ban).each do |action|
      describe "#{action}" do
        it 'should work with admin' do
          login_admin!
          t = create(:topic, user: current_user, title: 'new topic 3')
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          expect(response.status).to eq(200)
        end

        it 'should not work with normal user' do
          login_user!
          t = create(:topic, title: 'new topic 3')
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          expect(response.status).to eq(403)

          t = create(:topic, user: current_user, title: 'new topic 3')
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          expect(response.status).to eq(403)
        end
      end
    end

    %w(close open).each do |action|
      describe "#{action}" do
        it 'should work with admin' do
          login_admin!
          t = create(:topic, user: current_user, title: 'new topic 3')
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          expect(response.status).to eq(200)
        end

        it 'should work with owner' do
          login_user!
          t = create(:topic, title: 'new topic 3', user: current_user)
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          expect(response.status).to eq(200)
        end

        it 'should not work with other users' do
          login_user!
          t = create(:topic, title: 'new topic 3')
          post "/api/v3/topics/#{t.id}/action.json?type=#{action}"
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
