class User
  module GithubRepository
    extend ActiveSupport::Concern

    included do
    end

    # GitHub 项目
    def github_repositories
      cache_key = github_repositories_cache_key
      items = Homeland.file_store.read(cache_key)
      if items.nil?
        GithubRepoFetcherJob.perform_later(id)
        items = []
      end
      items.take(10)
    end

    def github_repositories_cache_key
      "github-repos:#{github}:1"
    end

    def github_repo_api_url
      github_login = self.github || self.login
      resource_name = organization? ? "orgs" : "users"
      "https://api.github.com/#{resource_name}/#{github_login}/repos?type=owner&sort=pushed&client_id=#{Setting.github_token}&client_secret=#{Setting.github_secret}"
    end

    module ClassMethods
      def fetch_github_repositories(user_id)
        user = User.find_by(id: user_id)
        return unless user

        url = user.github_repo_api_url
        begin
          json = Timeout.timeout(10) { open(url).read }
        rescue => e
          Rails.logger.error("GitHub Repositiory fetch Error: #{e}")
          Homeland.file_store.write(user.github_repositories_cache_key, [], expires_in: 1.minutes)
          return
        end

        items = JSON.parse(json)
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
        Homeland.file_store.write(user.github_repositories_cache_key, items, expires_in: 15.days)
        items
      end
    end
  end
end
