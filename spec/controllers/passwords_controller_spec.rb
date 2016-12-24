require 'rails_helper'

describe PasswordsController, type: :controller do
  describe ':new' do
    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    it 'should render new tempalte' do
      get :new
      expect(response).to be_success
    end

    it 'should redirect to sso login' do
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :new
      expect(response.status).to eq(302)
      expect(response.location).to include("/auth/sso")
    end
  end


  describe ':create' do
    let(:user) { create(:user) }
    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    it 'should work' do
      post :create, params: { user: { email: user.email } }
      expect(response).to be_success
    end
    it 'should redirect to sign in path after success' do
      allow_any_instance_of(ActionController::Base).to receive(:verify_rucaptcha?).and_return(true)
      post :create, params: { user: { email: user.email } }
      expect(response).to redirect_to('/account/sign_in')
    end
  end
end
