require 'rails_helper'

describe HomeController, type: :controller do
  describe ':index' do
    let(:user) { create :user }
    it 'should show register link if user not signed in' do
      get :index
      expect(response).to be_success
      expect(response.body).to match(/注册/)
    end

    it 'should not show register link if sso enabled' do
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :index
      expect(response).to be_success
      expect(response.body).not_to match(/注册/)
    end

    it 'should have hot topic lists if user is signed in' do
      sign_in user

      get :index
      expect(response.body).to match(/社区精华帖/)
    end
  end
end
