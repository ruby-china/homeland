class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "notifications_count/#{current_user_id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
