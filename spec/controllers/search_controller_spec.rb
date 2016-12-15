require 'rails_helper'

describe SearchController, type: :controller do
  describe '/search/users' do
    let(:user  ) { create(:user, name: 'bbbsjskssk') }
    let(:followings ) { [create(:user), create(:user)] }
    let(:user_f) { create(:user, following_ids: followings.map(&:id)) }

    it 'with params' do
      sign_in user
      get :users, params: { q: user.login }
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]).to include('login', 'name', 'avatar_url')
      expect(json.map {|j|j['login']}).to include user.login
      expect(json.map {|j|j['name']}).to include user.name
      expect(json.map {|j|j['avatar_url']}).to include user.large_avatar_url
    end

    it 'without params' do
      sign_in user_f
      get :users
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]).to include('login', 'name', 'avatar_url')
      expect(json.map {|j|j['login']}).to match followings.map(&:login)
      expect(json.map {|j|j['name']}).to match followings.map(&:name)
      expect(json.map {|j|j['avatar_url']}).to match followings.map(&:large_avatar_url)
    end
  end

  describe '/search' do\
    let(:topic) { create(:topic) }
    it 'should work' do
      get :index, params: { q: topic.title }
      expect(response.body).to match(Regexp.new("<div class=\"title\"><a href=\"/topics/#{topic.id}\"><em>#{topic.title}</em></a></div>"))
    end
  end

end
