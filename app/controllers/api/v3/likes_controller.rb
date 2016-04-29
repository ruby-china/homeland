module Api
  module V3
    class LikesController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!

      before_action do
        requires! :obj_type, values: %w(topic reply)
        requires! :obj_id
      end

      ##
      # 赞一个信息
      #
      # POST /api/v3/likes
      #
      # params:
      #   obj_type - [topic, reply]
      #   obj_id - 用于 Push 的设备信息
      #
      def create
        current_user.like(likeable)
        data = { obj_type: params[:obj_type], obj_id: likeable.id, count: likeable.likes_count }
        render json: data
      end

      ##
      # 取消之前的赞
      #
      # DELETE /api/v3/likes
      #
      # params:
      #   obj_type - [topic, reply]
      #   obj_id - 用于 Push 的设备信息
      #
      def destroy
        current_user.unlike(likeable)
        data = { obj_type: params[:obj_type], obj_id: likeable.id, count: likeable.likes_count }
        render json: data
      end

      private

      def likeable
        return @likeable if defined? @likeable
        @likeable =
          if params[:obj_type] == 'topic'
            Topic.find(params[:obj_id])
          else
            Reply.find(params[:obj_id])
          end
      end
    end
  end
end
