# frozen_string_literal: true

require "test_helper"

class NotifyTopicJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test ".perform" do
    Topic.stub(:notify_topic_created, 321) do
      NotifyTopicJob.perform_now(321)
    end
  end
end
