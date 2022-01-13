# frozen_string_literal: true

module Scheduler
  # cleanup spam topic at 1 month ago
  class TotalUserStatsJob < ApplicationJob
    def perform
      User.find_each.each do |user|
        user.monthly_replies_count.update(value: user.replies.where("created_at > ?", 1.month.ago).count)
        user.yearly_replies_count.update(value: user.replies.where("created_at > ?", 1.year.ago).count)
      end
    end
  end
end
