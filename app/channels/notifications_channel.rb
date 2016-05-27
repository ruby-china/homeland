class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    logger.info "current connections: #{ActionCable.server.connections.count}"
    if self.current_user_id
      stream_from "notifications_count/#{self.current_user_id}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
