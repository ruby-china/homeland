
module V3
  class Notifications < Grape::API
    resources :notifications do
      before do
        doorkeeper_authorize!
      end
      
      desc %(获取当前用户的通知列表。
**NOTE**:（此接口不会讲取到的通知设成已读，你需要调用一下 /notifications/read）)
      params do
        optional :offset, type: Integer, default: 0
        optional :limit, type: Integer, default: 20, values: 1..150
      end
      get "", each_serializer: NotificationSerializer, root: "notifications" do
        @notifications = current_user.notifications.recent.offset(params[:offset]).limit(params[:limit])
        render @notifications
      end
      
      desc "将当前用户的一些通知设成已读状态"
      params do
        requires :ids, type: Array
      end
      post "read" do
        if params[:ids].length > 0
          @notifications = current_user.notifications.where(:_id.in => params[:ids])
          current_user.read_notifications(@notifications)
        end
        { ok: 1 }
      end

      desc "删除当前用户的所有通知"
      delete "all" do
        current_user.notifications.delete_all
        { ok: 1 }
      end

      desc "删除当前用户的某个通知"
      delete ":id" do
        @notification = current_user.notifications.find params[:id]
        @notification.destroy
        { ok: 1 }
      end
    end
  end
end