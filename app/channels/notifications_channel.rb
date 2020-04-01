# frozen_string_literal: true

class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_count/#{self.current_user_id}"
  end
end
