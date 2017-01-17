require 'rails_helper'

describe SearchController, type: :controller do
  describe '/search/users' do
    let(:user) { create(:user) }
    let(:users) { [create(:user), create(:user)] }

    it 'should work' do
      sign_in user
      allow(User).to receive(:search).and_return(users)
      get :users
      res = JSON.parse(response.body)
      expect(response).to be_success
      expect(res[0]).to include('login', 'name', 'avatar_url')
      expect(res.map {|j|j['login']}).to match users.map(&:login)
      expect(res.map {|j|j['name']}).to match users.map(&:name)
      expect(res.map {|j|j['avatar_url']}).to match users.map(&:large_avatar_url)
    end
  end
end
