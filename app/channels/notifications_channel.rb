# frozen_string_literal: true

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    logger.info "current connections: #{ActionCable.server.connections.count}"
    if self.current_user_id
      stream_from "notifications_count/#{self.current_user_id}"
    end
  end
end
