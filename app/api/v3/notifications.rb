
module V3
  class Notifications < Grape::API
    resources :notifications do
      before do
        doorkeeper_authorize!
      end
      
      desc "Get notifications of current user, this API won't mark notifications as read"
      params do
        optional :offset, type: Integer, default: 0
        optional :limit, type: Integer, default: 20, values: 1..150
      end
      get "", each_serializer: NotificationSerializer, root: "notifications" do
        @notifications = current_user.notifications.recent.offset(params[:offset]).limit(params[:limit])
        render @notifications
      end
      
      desc "Mark notifications as read"
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

      desc "Delete all notifications of current user"
      delete "all" do
        current_user.notifications.delete_all
        { ok: 1 }
      end

      desc "Delete a notification of current user"
      delete ":id" do
        @notification = current_user.notifications.find params[:id]
        @notification.destroy
        { ok: 1 }
      end
    end
  end
end