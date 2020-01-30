# frozen_string_literal: true

require "spec_helper"

describe DevicesController do
  let(:user) { create(:user) }

  it "DELETE /devices/:id" do
    sign_in user
    device = create(:device, user: user)

    assert_equal false, device.new_record?
    assert_changes -> { user.devices.count }, -1 do
      delete device_path(device.id)
    end
    assert_redirected_to oauth_applications_path
    assert_equal 0, user.devices.where(id: device.id).count
  end

  it "require login" do
    device = create(:device, user: user)

    assert_no_changes -> { delete device_path(device.id) } do
      delete device_path(device.id)
    end
    assert_equal 302, response.status
  end
end
