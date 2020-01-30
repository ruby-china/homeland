# frozen_string_literal: true

require "test_helper"

class NotifyReplyJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test ".perform" do
    Reply.stub(:notify_reply_created, 123) do
      NotifyReplyJob.perform_now(123)
    end
  end
end
