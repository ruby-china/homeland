module Api
  module V3
    class NotificationsController < ApplicationController
      before_action :doorkeeper_authorize!

      # 用户的通知列表
      def index
        optional! :offset, default: 0
        optional! :limit, default: 20, values: 1..150

        @notifications = Notification.where(user_id: current_user.id).order('id desc')
                                     .offset(params[:offset])
                                     .limit(params[:limit])

        render json: @notifications
      end

      # 将当前用户的一些通知设成已读状态
      def read
        requires! :ids

        if params[:ids].length > 0
          @notifications = current_user.notifications.where(id: params[:ids])
          Notification.read!(@notifications.collect(&:id))
        end

        render json: { ok: 1 }, status: 201
      end

      # 删除当前用户的所有通知
      def all
        current_user.notifications.delete_all
        render json: { ok: 1 }
      end

      # 获得未读通知数量
      def unread_count
        render json: { count: Notification.unread_count(current_user) }
      end

      # 删除当前用户的某个通知
      def destroy
        @notification = current_user.notifications.find(params[:id])
        @notification.destroy
        render json: { ok: 1 }
      end
    end
  end
end
