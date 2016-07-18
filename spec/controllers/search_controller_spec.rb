require 'rails_helper'

describe SearchController, type: :controller do
  describe '/search/users' do
    it 'should work' do
      u = create(:user, name: 'bbbsjskssk')
      sign_in u
      get :users, params: { q: u.login }
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json[0]).to include('login', 'name', 'avatar_url')
      expect(json[0]['login']).to eq u.login
      expect(json[0]['name']).to eq u.name
      expect(json[0]['avatar_url']).to eq u.large_avatar_url
    end
  end
end
