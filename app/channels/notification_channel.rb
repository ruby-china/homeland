class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_count/#{current_user.id}"
  end

  def unsubscribed
  end
end
