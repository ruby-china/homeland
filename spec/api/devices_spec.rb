require 'rails_helper'

describe 'API V3', 'devices', type: :request do
  let(:token) { SecureRandom.hex }

  describe 'POST /api/v3/devices.json' do
    it 'require login' do
      post '/api/v3/devices.json', kind: 'ios', token: token
      expect(response.status).to eq(401)
    end

    it 'should be ok' do
      login_user!
      expect {
        post '/api/v3/devices.json', kind: 'ios', token: token
      }.to change(current_user.devices.ios, :count).by(1)
      expect(response.status).to eq(201)
      expect(current_user.devices.ios.pluck(:token)).to include(token)

      expect {
        post '/api/v3/devices.json', kind: 'android', token: token
      }.to change(current_user.devices.android, :count).by(1)
      expect(response.status).to eq(201)
      expect(current_user.devices.android.pluck(:token)).to include(token)
    end

    it 'should not be ok' do
      login_user!
      expect {
        post '/api/v3/devices.json', kind: 'ios'
      }.to change(Device, :count).by(0)
      expect(response.status).to eq(400)

      expect {
        post '/api/v3/devices.json', kind: 'foo', token: token
      }.to change(Device, :count).by(0)
      expect(response.status).to eq(400)
    end
  end

  describe 'DELETE /api/v3/likes.json' do
    let(:token) { SecureRandom.hex }
    it 'require login' do
      delete '/api/v3/devices.json', kind: 'bb'
      expect(response.status).to eq(400)

      delete '/api/v3/devices.json', kind: 'ios'
      expect(response.status).to eq(400)

      delete '/api/v3/devices.json', kind: 'ios', token: token
      expect(response.status).to eq(401)

      delete '/api/v3/devices.json', kind: 'android', token: token
      expect(response.status).to eq(200)
    end

    it 'should be ok' do
      login_user!
      android = Device.create(user: current_user, kind: 'android', token: SecureRandom.hex)
      ios = Device.create(user: current_user, kind: 'ios', token: SecureRandom.hex)

      expect {
        delete '/api/v3/devices.json', kind: 'android', token: android.token
      }.to change(current_user.devices.android, :count).by(-1)
      expect(response.status).to eq(200)
      expect(current_user.devices.android.pluck(:token)).not_to include(android.token)

      expect {
        delete '/api/v3/devices.json', kind: 'ios', token: ios.token
      }.to change(current_user.devices.ios, :count).by(-1)
      expect(response.status).to eq(200)
      expect(current_user.devices.ios.pluck(:token)).not_to include(ios.token)
    end
  end
end
