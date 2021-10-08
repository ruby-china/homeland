# frozen_string_literal: true

module Api
  module V3
    class DevicesController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!

      before_action do
        requires! :platform, type: String, values: %w[ios android]
        requires! :token, type: String
      end

      # 记录用户 Device 信息，用于 Push 通知。
      #
      # POST /api/v3/devices
      #
      # @note 请在每次用户打开 App 的时候调用此 API 以便更新 Token 的 last_actived_at 让服务端知道这个设备还活着。
      #   Push 将会忽略那些超过两周的未更新的设备。
      #
      # @param platform [String] 平台类型 [ios, android]
      # @param token [String] 用于 Push 的设备信息
      def create
        requires! :platform, type: String, values: %w[ios android]
        requires! :token, type: String

        @device = current_user.devices.find_or_initialize_by(platform: params[:platform].downcase,
          token: params[:token])
        @device.last_actived_at = Time.now
        @device.save!

        render json: {ok: 1}
      end

      # 删除 Device 信息，请注意在用户登出或删除应用的时候调用，以便能确保清理掉
      #
      # DELETE /api/v3/devices
      #
      # @param (see #create)
      def destroy
        requires! :platform, type: String, values: %w[ios android]
        requires! :token, type: String
        current_user.devices.where(platform: params[:platform].downcase, token: params[:token]).delete_all
        render json: {ok: 1}
      end
    end
  end
end
