# frozen_string_literal: true

require "spec_helper"

describe Api::V3::DevicesController do
  let(:token) { SecureRandom.hex }

  describe "POST /api/v3/devices.json" do
    it "require login" do
      post "/api/v3/devices.json", platform: "ios", token: token
      assert_equal 401, response.status
    end

    it "should be ok" do
      login_user!
      assert_changes -> { current_user.devices.ios.count }, 1 do
        post "/api/v3/devices.json", platform: "ios", token: token
      end
      assert_equal 200, response.status
      assert_includes current_user.devices.ios.pluck(:token), token

      assert_changes -> { current_user.devices.ios.count }, 1 do
        post "/api/v3/devices.json", platform: "ios", token: SecureRandom.hex
      end
      assert_equal 200, response.status
      assert_equal 2, current_user.devices.ios.pluck(:token).count

      assert_changes -> { current_user.devices.android.count }, 1 do
        post "/api/v3/devices.json", platform: "android", token: token
      end
      assert_equal 200, response.status
      assert_includes current_user.devices.android.pluck(:token), token
    end

    it "should not be ok" do
      login_user!
      assert_no_changes -> { Device.count } do
        post "/api/v3/devices.json", platform: "ios"
      end
      assert_equal 400, response.status

      assert_no_changes -> { Device.count } do
        post "/api/v3/devices.json", platform: "foo", token: token
      end
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

      assert_changes -> { current_user.devices.android.count }, -1 do
        delete "/api/v3/devices.json", platform: "android", token: android.token
      end
      assert_equal 200, response.status
      refute_includes current_user.devices.android.pluck(:token), android.token

      assert_changes -> { current_user.devices.ios.count }, -1 do
        delete "/api/v3/devices.json", platform: "ios", token: ios.token
      end
      assert_equal 200, response.status
      refute_includes current_user.devices.ios.pluck(:token), token
    end
  end
end
