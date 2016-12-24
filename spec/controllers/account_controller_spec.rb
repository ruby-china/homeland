require 'rails_helper'

describe AccountController, type: :controller do
  describe ':new' do
    before { request.env['devise.mapping'] = Devise.mappings[:user] }

    it 'should render new template' do
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

  describe ':update' do
    let(:user) { create :user }
    before { request.env['devise.mapping'] = Devise.mappings[:user] }
    it 'should work' do
      sign_in user
      put :update, params: { user: { location: 'BeiJing', profiles: { alipay: 'alipay' } } }
      expect(response).to redirect_to(action: :edit)
    end
  end

  describe ':create' do
    let(:user) { create :user }
    before { request.env['devise.mapping'] = Devise.mappings[:user] }
    it 'should work' do
      allow_any_instance_of(ActionController::Base).to receive(:verify_rucaptcha?).and_return(true)
      post :create, params: { format: :js, user: { login: 'newlogin', email: 'newlogin@email.com', password: 'password' } }
      expect(response).to be_success
    end
  end

  describe ':destroy' do
    let(:user) { create :user }
    before { request.env['devise.mapping'] = Devise.mappings[:user] }
    it 'should redirect to root path after success' do
      sign_in user
      delete :destroy, params: { user: { current_password: user.password } }
      expect(response).to redirect_to(root_path)
    end

    it 'should render edit after failure' do
      sign_in user
      delete :destroy, params: { user: { current_password: 'invalid password' } }
      expect(response).to be_success
    end
  end
end
