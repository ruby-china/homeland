require 'rails_helper'

describe 'API V3', 'users', type: :request do
  describe 'GET /api/v3/users.json' do
    before do
      create_list(:user, 10)
    end

    it 'should work' do
      get '/api/v3/users.json'
      expect(response.status).to eq 200
      expect(json['users'].size).to eq User.count
      expect(json['users'][0]).to include(*%w(id name login avatar_url))
    end

    it 'should work :limit' do
      get '/api/v3/users.json', limit: 2
      expect(response.status).to eq 200
      expect(json['users'].size).to eq 2
    end
  end

  describe 'GET /api/v3/users/me.json' do
    it 'should 403 when not login' do
      get '/api/v3/users/me.json'
      expect(response.status).to eq 401
    end

    it 'should work' do
      login_user!
      get '/api/v3/users/me.json'
      expect(response.status).to eq 200
      expect(json['user']['login']).to eq(current_user.login)
      expect(json['user']['email']).to eq(current_user.email)
    end
  end

  describe 'GET /api/v3/users/:login.json' do
    it 'should get user details with list of topics' do
      user = create(:user, name: 'test user', login: 'test_user', email: 'foobar@gmail.com', email_public: true)
      get '/api/v3/users/test_user.json'
      expect(response.status).to eq 200
      fields = %w(id name login email avatar_url location company twitter github website bio tagline
                  topics_count replies_count following_count followers_count favorites_count
                  level level_name)
      expect(json['user']).to include(*fields)
      fields.reject { |f| f == 'avatar_url' }.each do |field|
        expect(json['user'][field]).to eq user.send(field)
      end
      expect(json['meta']).to include(*%w(blocked followed))
    end

    it 'should hidden email when email_public is false' do
      create(:user, name: 'test user',
                    login: 'test_user',
                    email: 'foobar@gmail.com',
                    email_public: false)
      get '/api/v3/users/test_user.json'
      expect(response.status).to eq 200
      expect(json['user']['email']).to eq ''
    end

    it 'should get right meta info' do
      u = create(:user, name: 'test user',
                        login: 'test_user',
                        email: 'foobar@gmail.com',
                        email_public: false)
      login_user!
      current_user.follow_user(u)
      current_user.block_user(u.id)
      get '/api/v3/users/test_user.json'
      expect(response.status).to eq 200
      expect(json['meta']['blocked']).to eq(true)
      expect(json['meta']['followed']).to eq(true)
    end

    it 'should not hidden email when current_user itself' do
      login_user!
      get "/api/v3/users/#{current_user.login}.json"
      expect(response.status).to eq 200
      expect(json['user']['email']).to eq current_user.email
    end
  end

  describe 'GET /api/v3/users/:login/topics.json' do
    let(:user) { create(:user) }

    describe 'recent order' do
      it 'should work' do
        @topics = create_list(:topic, 3, user: user)
        get "/api/v3/users/#{user.login}/topics.json", offset: 0, limit: 2
        expect(response.status).to eq 200
        expect(json['topics'].size).to eq 2
        fields = %w(id title user node_name node_id last_reply_user_id
                    last_reply_user_login created_at updated_at replies_count)
        expect(json['topics'][0]).to include(*fields)
        expect(json['topics'][0]['id']).to eq @topics[2].id
        expect(json['topics'][1]['id']).to eq @topics[1].id
      end
    end

    describe 'hot order' do
      it 'should work' do
        @hot_topic = create(:topic, user: user, likes_count: 4)
        @topics = create_list(:topic, 3, user: user)

        get "/api/v3/users/#{user.login}/topics.json", order: 'likes', offset: 0, limit: 3
        expect(response.status).to eq 200
        expect(json['topics'].size).to eq 3
        expect(json['topics'][0]['id']).to eq @hot_topic.id
      end
    end

    describe 'hot order' do
      it 'should work' do
        @hot_topic = create(:topic, user: user, replies_count: 4)
        @topics = create_list(:topic, 3, user: user)

        get "/api/v3/users/#{user.login}/topics.json", order: 'replies', offset: 0, limit: 3
        expect(response.status).to eq 200
        expect(json['topics'].size).to eq 3
        expect(json['topics'][0]['id']).to eq @hot_topic.id
      end
    end
  end

  describe 'GET /api/v3/users/:login/replies.json' do
    let(:user) { create(:user) }
    let(:topic) { create(:topic, title: 'Test topic title') }

    describe 'recent order' do
      it 'should work' do
        @replies = create_list(:reply, 3, user: user, topic: topic)
        get "/api/v3/users/#{user.login}/replies.json", offset: 0, limit: 2
        expect(json['replies'].size).to eq 2
        fields = %w(id user body_html topic_id topic_title)
        expect(json['replies'][0]).to include(*fields)
        expect(json['replies'][0]['id']).to eq @replies[2].id
        expect(json['replies'][0]['topic_title']).to eq topic.title
        expect(json['replies'][1]['id']).to eq @replies[1].id
      end
    end
  end

  describe 'GET /api/v3/users/:login/favorites.json' do
    let(:user) { create(:user) }

    it 'should work' do
      @topics = create_list(:topic, 4, user: user)
      user.favorite_topic(@topics[0].id)
      user.favorite_topic(@topics[1].id)
      user.favorite_topic(@topics[3].id)
      get "/api/v3/users/#{user.login}/favorites.json", offset: 1, limit: 2
      expect(response.status).to eq 200
      expect(json['topics'].size).to eq 2
      fields = %w(id title user node_name node_id last_reply_user_id
                  last_reply_user_login created_at updated_at replies_count)
      expect(json['topics'][0]).to include(*fields)
      expect(json['topics'][0]['id']).to eq @topics[1].id
      expect(json['topics'][1]['id']).to eq @topics[0].id
    end
  end

  describe 'GET /api/v3/users/:login/followers.json' do
    let(:user) { create(:user) }

    it 'should work' do
      @users = create_list(:user, 3)
      @users.each do |u|
        u.follow_user(user)
      end

      get "/api/v3/users/#{user.login}/followers.json", offset: 0, limit: 2
      expect(response.status).to eq 200
      expect(json['followers'].size).to eq 2
      expect(json['followers'][0]).to include(*%w(id name login avatar_url))
      expect(json['followers'][0]['login']).to eq @users[0].login
    end
  end

  describe 'GET /api/v3/users/:login/blocked.json' do
    let(:user) { create(:user) }

    it 'require login' do
      get "/api/v3/users/#{user.login}/blocked.json"
      expect(response.status).to eq 401
    end

    it 'only visit itself' do
      login_user!
      get "/api/v3/users/#{user.login}/blocked.json"
      expect(response.status).to eq 403
    end

    it 'should work' do
      @users = create_list(:user, 3)
      login_user!

      @users.each do |u|
        current_user.block_user(u.id)
      end

      get "/api/v3/users/#{current_user.login}/blocked.json", offset: 0, limit: 2
      expect(response.status).to eq 200
      expect(json['blocked'].size).to eq 2
      expect(json['blocked'][0]).to include(*%w(id name login avatar_url))
      expect(json['blocked'][0]['login']).to eq @users[0].login
    end
  end

  describe 'GET /api/v3/users/:login/following.json' do
    let(:user) { create(:user) }

    it 'should work' do
      @users = create_list(:user, 3)
      @users.each do |u|
        user.follow_user(u)
      end

      get "/api/v3/users/#{user.login}/following.json", offset: 0, limit: 2
      expect(response.status).to eq 200
      expect(json['following'].size).to eq 2
      expect(json['following'][0]).to include(*%w(id name login avatar_url))
      expect(json['following'][0]['login']).to eq @users[0].login
    end
  end

  describe 'POST /api/v3/users/:login/follow.json / unfollow' do
    let(:user) { create(:user) }

    it 'should 401 when nologin' do
      post "/api/v3/users/#{user.login}/follow.json"
      expect(response.status).to eq 401

      post "/api/v3/users/#{user.login}/unfollow.json"
      expect(response.status).to eq 401
    end

    it 'should follow work' do
      login_user!
      post "/api/v3/users/#{user.login}/follow.json"
      expect(response.status).to eq 200
      expect(json['ok']).to eq 1
      current_user.reload
      expect(current_user.followed?(user)).to eq true
    end

    it 'should unfollow work' do
      login_user!
      current_user.follow_user(user)
      post "/api/v3/users/#{user.login}/unfollow.json"
      expect(response.status).to eq 200
      expect(json['ok']).to eq 1
      current_user.reload
      expect(current_user.followed?(user)).to eq false
    end
  end

  describe 'POST /api/v3/users/:login/block.json / unblock.json' do
    let(:user) { create(:user) }

    it 'should 401 when nologin' do
      post "/api/v3/users/#{user.login}/block.json"
      expect(response.status).to eq 401

      post "/api/v3/users/#{user.login}/unblock.json"
      expect(response.status).to eq 401
    end

    it 'should work' do
      login_user!
      post "/api/v3/users/#{user.login}/block.json"
      expect(response.status).to eq 200
      expect(json['ok']).to eq 1
      current_user.reload
      expect(current_user.blocked_user?(user)).to eq true
    end

    it 'should unfollow' do
      login_user!
      current_user.block_user(user.id)
      post "/api/v3/users/#{user.login}/unblock.json"
      expect(response.status).to eq 200
      expect(json['ok']).to eq 1
      current_user.reload
      expect(current_user.blocked_user?(user)).to eq false
    end
  end
end
