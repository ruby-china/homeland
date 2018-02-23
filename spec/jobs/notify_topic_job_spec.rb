# frozen_string_literal: true

require "rails_helper"

describe NotifyTopicJob, type: :job do
  describe ".perform" do
    it "should work" do
      expect(Topic).to receive(:notify_topic_created).with(321).once
      NotifyTopicJob.perform_later(321)
    end
  end
end
