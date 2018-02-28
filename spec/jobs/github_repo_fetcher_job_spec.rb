# frozen_string_literal: true

require "rails_helper"

describe GitHubRepoFetcherJob, type: :job do
  describe ".perform" do
    it "should work" do
      expect(User).to receive(:fetch_github_repositories).with(234).once
      GitHubRepoFetcherJob.perform_later(234)
    end
  end
end
