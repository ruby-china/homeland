# frozen_string_literal: true

require "test_helper"

class GitHubRepoFetcherJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test ".perform" do
    User.stub(:fetch_github_repositories, 234) do
      GitHubRepoFetcherJob.perform_now(234)
    end
  end
end
