# frozen_string_literal: true

require "test_helper"

class Scheduler::SpamCleanupJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test ".perform" do
    create_list(:topic, 3, grade: :ban, created_at: 40.days.ago)

    topics1 = create_list(:topic, 2, created_at: 40.days.ago)
    topics2 = create_list(:topic, 2, grade: :ban, created_at: 3.days.ago)
    topics3 = create_list(:topic, 1, created_at: 6.days.ago)

    assert_equal 8, Topic.count
    assert_equal 5, Topic.ban.count

    Scheduler::SpamCleanupJob.perform_now

    assert_equal 5, Topic.count
    assert_equal 2, Topic.ban.count
    expected_ids = topics1.collect(&:id) + topics2.collect(&:id) + topics3.collect(&:id)
    assert_equal expected_ids.sort, Topic.pluck(:id).sort
  end
end
