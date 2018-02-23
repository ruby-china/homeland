# frozen_string_literal: true

require "rails_helper"

describe DevicesController, type: :controller do
  let(:user) { create(:user) }
  let!(:device) { create(:device, user: user) }

  it "DELETE /devices/:id" do
    sign_in user
    expect(device.new_record?).to eq false
    expect do
      delete :destroy, params: { id: device.id }
    end.to change(user.devices, :count).by(-1)
    expect(response).to redirect_to(oauth_applications_path)
    expect(user.devices.where(id: device.id).count).to eq 0
  end

  it "require login" do
    expect do
      delete :destroy, params: { id: device.id }
    end.to change(user.devices, :count).by(0)
    expect(response.status).to eq(302)
  end
end
