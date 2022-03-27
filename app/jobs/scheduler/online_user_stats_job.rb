# frozen_string_literal: true

module Scheduler
  # Cleanup inactive user record from redis
  class OnlineUserStatsJob < ApplicationJob
    def perform
      User.cleanup_inactive_online_stats
    end
  end
end
