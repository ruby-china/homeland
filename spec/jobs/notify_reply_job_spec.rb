# frozen_string_literal: true

require "rails_helper"

describe NotifyReplyJob, type: :job do
  describe ".perform" do
    it "should work" do
      expect(Reply).to receive(:notify_reply_created).with(123).once
      NotifyReplyJob.perform_later(123)
    end
  end
end
