# frozen_string_literal: true

module Scheduler
  # cleanup spam topic at 1 month ago
  class SpamCleanupJob < ApplicationJob
    def perform
      # Clean banned topics before 1 month ago
      Topic.ban.where("created_at < ?", 1.month.ago).delete_all
    end
  end
end
