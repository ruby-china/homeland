# frozen_string_literal: true

class DevicesController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @device = current_user.devices.find(params[:id])
    @device.delete
    redirect_to oauth_applications_path, notice: "设备信息已删除"
  end
end
