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
end
