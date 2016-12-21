require 'rails_helper'

describe AccountController, type: :controller do
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

  describe ':edit' do
    let(:user) { create :user }

    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    it 'should work' do
      sign_in user
      get :edit
      expect(response).to be_success
      expect(response.body).to include('修改密码')
    end

    it 'should not contain password panel' do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :edit
      expect(response).to be_success
      expect(response.body).not_to include('修改密码')
    end
  end
end
