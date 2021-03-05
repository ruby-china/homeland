# frozen_string_literal: true

class User
  module GitHubRepository
    extend ActiveSupport::Concern

    included do
    end

    def github_repositories
      cache_key = github_repositories_cache_key
      items = Homeland.file_store.read(cache_key)
      if items.nil?
        GitHubRepoFetcherJob.perform_later(id)
        items = []
      end
      items.take(10)
    end

    def github_repositories_cache_key
      "github-repos:#{github}:1"
    end

    def github_repos_path
      return nil if github.blank?
      resource_name = organization? ? "orgs" : "users"
      "/#{resource_name}/#{github}/repos?type=owner&sort=pushed"
    end

    module ClassMethods
      def fetch_github_repositories(user_id)
        user = User.find_by(id: user_id)
        return unless user
        return if user.github_repos_path.blank?

        begin
          conn = Faraday.new("https://api.github.com") do |conn|
            conn.basic_auth Setting.github_api_key, Setting.github_api_secret
          end
          resp = conn.get(user.github_repos_path)
        rescue => e
          Rails.logger.error("GitHub Repositiory fetch Error: #{e}")
          Homeland.file_store.write(user.github_repositories_cache_key, [], expires_in: 1.minutes)
          return
        end

        items = []
        if resp.status == 200
          items = JSON.parse(resp.body)
          items = items.collect do |a1|
            {
              name: a1["name"],
              url: a1["html_url"],
              watchers: a1["watchers"],
              language: a1["language"],
              description: a1["description"]
            }
          end
          items.sort! { |a, b| b[:watchers] <=> a[:watchers] }.take(10)
        end

        Homeland.file_store.write(user.github_repositories_cache_key, items, expires_in: 15.days)
        items
      end
    end
  end
end
