
module V3
  class Notifications < Grape::API
    resources :notifications do
      before do
        doorkeeper_authorize!
      end
      
      # Get notifications of current user, this Api won't mark notifications as read
      # require authentication
      # params[:page]
      # params[:per_page]: default is 20
      # Example
      #   /Api/notifications.json?page=1&per_page=20
      get do
        @notifications = current_user.notifications.recent.paginate page: params[:page], per_page: params[:per_page] || 20
        present @notifications, with: V3::Entities::Notification
      end

      # Delete all notifications of current user
      # require authentication
      # params:
      #   NO
      # Example
      #   DELETE /Api/notifications.json
      delete do
        current_user.notifications.delete_all
        true
      end

      # Delete all notifications of current user
      # require authentication
      # params:
      #   id
      # Example
      #   DELETE /Api/notifications/1.json
      delete ":id" do
        @notification = current_user.notifications.find params[:id]
        @notification.destroy
        true
      end
    end
  end
end