# frozen_string_literal: true

require "rails_helper"

describe DevicesController, type: :controller do
  let(:user) { create(:user) }
  let!(:device) { create(:device, user: user) }

  it "DELETE /devices/:id" do
    sign_in user
    assert_equal false, device.new_record?
    expect do
      delete :destroy, params: { id: device.id }
    end.to change(user.devices, :count).by(-1)
    assert_redirected_to oauth_applications_path
    assert_equal 0, user.devices.where(id: device.id).count
  end

  it "require login" do
    expect do
      delete :destroy, params: { id: device.id }
    end.to change(user.devices, :count).by(0)
    assert_equal 302, response.status
  end
end
