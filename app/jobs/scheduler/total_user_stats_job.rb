# frozen_string_literal: true

module Scheduler
  # Count user replies count in recent
  class TotalUserStatsJob < ApplicationJob
    def perform(limit: 2000)
      users = User.where("replies_count > 0")
      users = if limit.to_i > 0
        users.order("updated_at desc").limit(limit)
      else
        users.where("replies_count > 0").order("updated_at desc").find_each
      end

      users.each do |user|
        user.monthly_replies_count.update(value: user.replies.where("created_at > ?", 1.month.ago).count)
        user.yearly_replies_count.update(value: user.replies.where("created_at > ?", 1.year.ago).count)
      end
    end
  end
end
