module Api
  module V3
    class LikesController < ApplicationController
      before_action :doorkeeper_authorize!

      before_action do
        requires! :obj_type, values: %w(topic reply)
        requires! :obj_id
      end

      # 记录用户 Device 信息，用于 Push 通知。
      # 请在每次用户打开 App 的时候调用此 API 以便更新 Token 的 last_actived_at 让服务端知道这个设备还活着。
      # Push 将会忽略那些超过两周的未更新的设备。
      #
      # params do
      #   requires :platform, type: String, values: %w(ios android)
      #   requires :token, type: String
      # end
      def create
        current_user.like(likeable)
        data = { obj_type: params[:obj_type], obj_id: likeable.id, count: likeable.likes_count }
        render json: data, status: 201
      end

      # desc '删除 Device 信息，请注意在用户登出或删除应用的时候调用，以便能确保清理掉'
      # params do
      #   requires :platform, type: String, values: %w(ios android)
      #   requires :token, type: String
      # end
      def destroy
        current_user.unlike(likeable)
        data = { obj_type: params[:obj_type], obj_id: likeable.id, count: likeable.likes_count }
        render json: data
      end

      private

      def likeable
        return @likeable if defined? @likeable
        if params[:obj_type] == 'topic'
          @likeable = Topic.find(params[:obj_id])
        else
          @likeable = Reply.find(params[:obj_id])
        end
        @likeable
      end
    end
  end
end
