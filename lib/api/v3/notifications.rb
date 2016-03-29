module API
  module V3
    class Notifications < Grape::API
      resources :notifications do
        before do
          doorkeeper_authorize!
        end

        params do
          optional :offset, type: Integer, default: 0
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        get '', each_serializer: NotificationSerializer, root: 'notifications' do
          @notifications = Notification.where(user_id: current_user.id).order('id desc').offset(params[:offset]).limit(params[:limit])
          render @notifications
        end

        desc '获得未读通知数量'
        get 'unread_count' do
          { count: Notification.unread_count(current_user) }
        end

        desc '将当前用户的一些通知设成已读状态'
        params do
          requires :ids, type: Array
        end
        post 'read' do
          if params[:ids].length > 0
            @notifications = current_user.notifications.where(id: params[:ids])
            Notification.read!(@notifications.collect(&:id))
          end
          { ok: 1 }
        end

        desc '删除当前用户的所有通知'
        delete 'all' do
          current_user.notifications.delete_all
          { ok: 1 }
        end

        desc '删除当前用户的某个通知'
        delete ':id' do
          @notification = current_user.notifications.find params[:id]
          @notification.destroy
          { ok: 1 }
        end
      end
    end
  end
end
