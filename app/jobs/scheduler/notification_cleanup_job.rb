# frozen_string_literal: true

module Scheduler
  # cleanup notifications at 1 years ago
  class NotificationCleanupJob < ApplicationJob
    def perform
      Notification.where("created_at < ?", 1.years.ago).delete_all
    end
  end
end
