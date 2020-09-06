# frozen_string_literal: true

module Scheduler
  class GitHubStatisticsFetcherJob < ApplicationJob
    queue_as :http_request

    # update github statistics
    def perform
      GitHubStatistic.fetch_github_repo_statistics
      GitHubStatistic.fetch_github_user_statistics
    end
  end
end
