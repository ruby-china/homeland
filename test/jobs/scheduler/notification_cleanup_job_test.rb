# frozen_string_literal: true

require "test_helper"

class Scheduler::NotificationCleanupJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test ".perform" do
    create_list(:notification, 3, created_at: 400.days.ago)
    create_list(:notification, 2, created_at: 200.days.ago)
    assert_equal 5, Notification.count
    assert_equal 3, Notification.where("created_at < ?", 1.years.ago).count

    Scheduler::NotificationCleanupJob.perform_now

    assert_equal 0, Notification.where("created_at < ?", 1.years.ago).count
    assert_equal 2, Notification.count
  end
end
