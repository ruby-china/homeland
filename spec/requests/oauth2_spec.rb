require 'rails_helper'
require 'oauth2'

describe 'OAuth2' do
  let(:password) { '123123' }
  let(:user) { FactoryBot.create(:user, password: password, password_confirmation: password) }
  let(:app) { FactoryBot.create(:application) }

  let(:client) do
    OAuth2::Client.new(app.uid, app.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
  end

  describe 'auth_code' do
    let(:grant) { FactoryBot.create(:access_grant, application: app, redirect_uri: "#{app.redirect_uri}/callback") }

    it 'should work' do
      expect do
        @access_token = client.auth_code.get_token(grant.token, redirect_uri: grant.redirect_uri)
      end.to change(Doorkeeper::AccessToken, :count).by(1)

      expect(@access_token.token).not_to be_nil

      # Refresh Token
      expect do
        @new_token = @access_token.refresh!
      end.to change(Doorkeeper::AccessToken, :count).by(1)
      expect(@new_token.token).not_to be_nil
      expect(@new_token.token).not_to eq @access_token.token
    end
  end

  describe 'password get_token' do
    it 'should work' do
      expect do
        @access_token = client.password.get_token(user.email, password)
      end.to change(Doorkeeper::AccessToken, :count).by(1)

      expect do
        @access_token = client.password.get_token(user.login, password)
      end.to change(Doorkeeper::AccessToken, :count).by(1)

      expect(@access_token.token).not_to be_nil

      # Refresh Token
      expect do
        @new_token = @access_token.refresh!
      end.to change(Doorkeeper::AccessToken, :count).by(1)
      expect(@new_token.token).not_to be_nil
      expect(@new_token.token).not_to eq @access_token.token
    end
  end
end
