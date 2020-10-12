# frozen_string_literal: true

class ApplicationController
  module UserNotifications
    extend ActiveSupport::Concern

    included do
      helper_method :unread_notify_count
    end

    def unread_notify_count
      return 0 if current_user.blank?
      @unread_notify_count ||= Notification.unread_count(current_user)
    end
  end
end
