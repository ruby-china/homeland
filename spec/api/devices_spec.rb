# frozen_string_literal: true

require "rails_helper"

describe "API V3", "devices", type: :request do
  let(:token) { SecureRandom.hex }

  describe "POST /api/v3/devices.json" do
    it "require login" do
      post "/api/v3/devices.json", platform: "ios", token: token
      assert_equal 401, response.status
    end

    it "should be ok" do
      login_user!
      expect do
        post "/api/v3/devices.json", platform: "ios", token: token
      end.to change(current_user.devices.ios, :count).by(1)
      assert_equal 200, response.status
      assert_includes current_user.devices.ios.pluck(:token), token

      expect do
        post "/api/v3/devices.json", platform: "ios", token: SecureRandom.hex
      end.to change(current_user.devices.ios, :count).by(1)
      assert_equal 200, response.status
      assert_equal 2, current_user.devices.ios.pluck(:token).count

      expect do
        post "/api/v3/devices.json", platform: "android", token: token
      end.to change(current_user.devices.android, :count).by(1)
      assert_equal 200, response.status
      assert_includes current_user.devices.android.pluck(:token), token
    end

    it "should not be ok" do
      login_user!
      expect do
        post "/api/v3/devices.json", platform: "ios"
      end.to change(Device, :count).by(0)
      assert_equal 400, response.status

      expect do
        post "/api/v3/devices.json", platform: "foo", token: token
      end.to change(Device, :count).by(0)
      assert_equal 400, response.status
    end
  end

  describe "DELETE /api/v3/likes.json" do
    let(:token) { SecureRandom.hex }
    it "require login" do
      delete "/api/v3/devices.json", platform: "bb", token: token
      assert_equal 401, response.status
    end

    it "validation params" do
      login_user!
      delete "/api/v3/devices.json", platform: "bb"
      assert_equal 400, response.status

      delete "/api/v3/devices.json", platform: "ios"
      assert_equal 400, response.status
    end

    it "should be ok" do
      login_user!
      android = Device.create(user: current_user, platform: "android", token: SecureRandom.hex)
      ios = Device.create(user: current_user, platform: "ios", token: SecureRandom.hex)

      expect do
        delete "/api/v3/devices.json", platform: "android", token: android.token
      end.to change(current_user.devices.android, :count).by(-1)
      assert_equal 200, response.status
      refute_includes current_user.devices.android.pluck(:token), android.token

      expect do
        delete "/api/v3/devices.json", platform: "ios", token: ios.token
      end.to change(current_user.devices.ios, :count).by(-1)
      assert_equal 200, response.status
      refute_includes current_user.devices.ios.pluck(:token), token
    end
  end
end
