require 'rails_helper'

describe SettingsController, type: :controller do
  let(:user) { create :user }

  describe ':show' do
    it 'should work' do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(false)
      get :show
      expect(response).to be_success
      expect(response.body).to include('更新资料')
      expect(response.body).to include('登陆密码')

      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :show
      expect(response.body).not_to include('登陆密码')
    end

    it 'should new work with non user' do
      get :show
      expect(response.status).to eq 302
    end
  end

  describe ':account' do
    it 'should work' do
      sign_in user
      get :account
      expect(response).to be_success
      expect(response.body).to include('绑定其他帐号用于登录')
      expect(response.body).to include('删除账号')
    end
  end

  describe ':password' do
    it 'should open password when not enable sso' do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(false)
      get :password
      expect(response).to be_success
      expect(response.body).to include('修改密码')
    end

    it 'should not open when sso enabled' do
      sign_in user
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      get :password
      expect(response.status).to eq 404
    end
  end

  describe ':update' do
    it 'should work' do
      sign_in user
      put :update, params: { user: { location: 'BeiJing', profiles: { alipay: 'alipay' } } }
      expect(response).to redirect_to(action: :show)

      put :update, params: { by: 'profile', user: { location: 'BeiJing', profiles: { alipay: 'alipay' } } }
      expect(response).to redirect_to(action: :profile)

      password_params = {
        current_password: user.password,
        password: '123',
        password_confirmation: '123123'
      }
      allow_any_instance_of(User).to receive(:update_with_password).and_return(true)
      put :update, params: { by: 'password', user: password_params }
      expect(response).to redirect_to('/account/sign_in')
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

  describe ':auto_unbind' do
    it 'should word' do
      sign_in user
      delete :auth_unbind, params: { id: user.login, provider: 'github' }
      expect(response).to redirect_to(account_setting_path)
    end

    it 'have no provider' do
      user.bind_service('provider' => 'github', 'uid' => 'ruby-china')
      user.bind_service('provider' => 'twitter', 'uid' => 'ruby-china')
      sign_in user
      delete :auth_unbind, params: { id: user.login, provider: 'github' }
      expect(response).to redirect_to(account_setting_path)
    end
  end
end
