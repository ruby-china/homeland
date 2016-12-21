require 'rails_helper'

describe Auth::SSOController, type: :controller do
  let(:sso_secret) { 'foo(*&@!12q36)' }

  describe 'GET /auth/sso/login' do
    let(:mock_ip) { '11.22.33.44' }
    before do
      @sso_url = "http://somesite.com/homeland-sso"

      request.host = Setting.domain

      allow(Setting).to receive(:sso).and_return({
        'enable' => true,
        'url'    => @sso_url,
        'secret' => sso_secret,
      })
      allow(Setting).to receive(:sso_enabled?).and_return(true)
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(mock_ip)
    end

    def get_sso(return_path)
      nonce = SecureRandom.hex
      dso = Homeland::SSO.new
      dso.nonce = nonce
      dso.register_nonce(return_path)

      sso = SingleSignOn.new
      sso.nonce = nonce
      sso.sso_secret = sso_secret
      sso
    end

    it 'can take over an account' do
      user_template = build(:user)
      sso = get_sso('/topics/123')
      sso.email = user_template.email
      sso.external_id = 'abc123'
      sso.name = 'Test SSO User'
      sso.username = 'test-sso-user'
      sso.bio = 'This is a bio text'
      sso.avatar_url = 'http://foobar.com/avatar/1.jpg'
      sso.admin = false

      get :login, params: Rack::Utils.parse_query(sso.payload)

      expect(response).to redirect_to('/topics/123')
      user = User.find_by_email(sso.email)
      expect(user.new_record?).to eq(false)
      expect(user.admin?).to eq(false)
      expect(user.login).to eq(sso.username)
      expect(user.name).to eq(sso.name)
      expect(user.bio).to eq(sso.bio)
      expect(user.sso).not_to eq(nil)
      expect(user.sso.uid).to eq(sso.external_id)
      expect(user.sso.username).to eq(sso.username)
      expect(user.sso.name).to eq(sso.name)
      expect(user.sso.email).to eq(sso.email)
      expect(user.sso.avatar_url).to eq(sso.avatar_url)
      expect(user.current_sign_in_ip).to eq(mock_ip)
      expect(user.current_sign_in_at).not_to eq(nil)
    end

    it 'can sign a exist user' do
      user = create(:user, name: nil, bio: nil)
      user.create_sso({ uid: 'abc1237161', last_payload: '' })

      sso = get_sso('/')
      sso.email = user.email
      sso.external_id = user.sso.uid
      sso.name = 'Test SSO User'
      sso.username = 'test-sso-user'
      sso.bio = 'This is a bio text'
      sso.avatar_url = 'http://foobar.com/avatar/1.jpg'

      expect do
        get :login, params: Rack::Utils.parse_query(sso.payload)
      end.to change(User, :count).by(0)

      expect(response).to redirect_to('/')
      user1 = User.find_by_id(user.id)
      expect(user1.name).to eq(sso.name)
      expect(user1.login).to eq(user.login)
      expect(user1.bio).to eq(sso.bio)
    end

    it 'can take an admin account' do
      user_template = build(:user)
      sso = get_sso('/hello/world')
      sso.email = user_template.email
      sso.external_id = 'abc123'
      sso.name = 'Test SSO User'
      sso.username = user_template.login
      sso.admin = true

      get :login, params: Rack::Utils.parse_query(sso.payload)
      expect(response).to redirect_to('/hello/world')
      user = User.find_by_email(sso.email)
      expect(user.admin?).to eq(true)
      expect(Setting.has_admin?(sso.email)).to eq(true)
    end
  end

  describe 'GET /auth/sso/provider' do
    let(:user) { create(:user) }

    before do
      allow(Setting).to receive(:sso).and_return({
        'secret' => sso_secret,
      })
      allow(Setting).to receive(:sso_provider_enabled?).and_return(true)

      @sso = SingleSignOn.new
      @sso.nonce = "mynonce"
      @sso.sso_secret = sso_secret
      @sso.return_sso_url = 'http://foobar.com/sso/callback'
    end

    it "should work" do
      sign_in user
      allow(Setting).to receive(:has_admin?).with(user.email).and_return(true)
      get :provider, params: Rack::Utils.parse_query(@sso.payload)
      expect(response.status).to eq(302)

      location = response.location
      # javascript code will handle redirection of user to return_sso_url
      expect(location).to match(/^http:\/\/foobar.com\/sso\/callback/)

      payload = location.split("?")[1]
      sso2 = SingleSignOn.parse(payload, @sso.sso_secret)

      expect(sso2.email).to eq(user.email)
      expect(sso2.name).to eq(user.name)
      expect(sso2.username).to eq(user.login)
      expect(sso2.external_id).to eq(user.id.to_s)
      expect(sso2.bio).to eq(user.bio)
      expect(sso2.avatar_url).not_to eq(nil)
      expect(sso2.admin).to eq(true)
    end

    it 'should work with sign in' do
      get :provider, params: Rack::Utils.parse_query(@sso.payload)
      expect(response).to redirect_to('/account/sign_in')

      expect(session[:return_to]).to match('/auth/sso/provider')
      expect(session[:return_to]).to eq(request.url)
    end
  end
end
