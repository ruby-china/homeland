# frozen_string_literal: true

class GitHubRepoFetcherJob < ApplicationJob
  queue_as :http_request

  def perform(user_id)
    User.fetch_github_repositories(user_id)
  end
end
