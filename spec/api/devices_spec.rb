# frozen_string_literal: true

require "rails_helper"

describe "API V3", "devices", type: :request do
  let(:token) { SecureRandom.hex }

  describe "POST /api/v3/devices.json" do
    it "require login" do
      post "/api/v3/devices.json", platform: "ios", token: token
      expect(response.status).to eq(401)
    end

    it "should be ok" do
      login_user!
      expect do
        post "/api/v3/devices.json", platform: "ios", token: token
      end.to change(current_user.devices.ios, :count).by(1)
      expect(response.status).to eq(200)
      expect(current_user.devices.ios.pluck(:token)).to include(token)

      expect do
        post "/api/v3/devices.json", platform: "ios", token: SecureRandom.hex
      end.to change(current_user.devices.ios, :count).by(1)
      expect(response.status).to eq(200)
      expect(current_user.devices.ios.pluck(:token).count).to eq 2

      expect do
        post "/api/v3/devices.json", platform: "android", token: token
      end.to change(current_user.devices.android, :count).by(1)
      expect(response.status).to eq(200)
      expect(current_user.devices.android.pluck(:token)).to include(token)
    end

    it "should not be ok" do
      login_user!
      expect do
        post "/api/v3/devices.json", platform: "ios"
      end.to change(Device, :count).by(0)
      expect(response.status).to eq(400)

      expect do
        post "/api/v3/devices.json", platform: "foo", token: token
      end.to change(Device, :count).by(0)
      expect(response.status).to eq(400)
    end
  end

  describe "DELETE /api/v3/likes.json" do
    let(:token) { SecureRandom.hex }
    it "require login" do
      delete "/api/v3/devices.json", platform: "bb", token: token
      expect(response.status).to eq 401
    end

    it "validation params" do
      login_user!
      delete "/api/v3/devices.json", platform: "bb"
      expect(response.status).to eq(400)

      delete "/api/v3/devices.json", platform: "ios"
      expect(response.status).to eq(400)
    end

    it "should be ok" do
      login_user!
      android = Device.create(user: current_user, platform: "android", token: SecureRandom.hex)
      ios = Device.create(user: current_user, platform: "ios", token: SecureRandom.hex)

      expect do
        delete "/api/v3/devices.json", platform: "android", token: android.token
      end.to change(current_user.devices.android, :count).by(-1)
      expect(response.status).to eq(200)
      expect(current_user.devices.android.pluck(:token)).not_to include(android.token)

      expect do
        delete "/api/v3/devices.json", platform: "ios", token: ios.token
      end.to change(current_user.devices.ios, :count).by(-1)
      expect(response.status).to eq(200)
      expect(current_user.devices.ios.pluck(:token)).not_to include(ios.token)
    end
  end
end
