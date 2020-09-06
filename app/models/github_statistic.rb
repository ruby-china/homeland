# frozen_string_literal: true
class GitHubStatistic < ApplicationRecord
  extend ActiveSupport::Concern

  validates :github_user, presence: true

  scope :current_month_data, -> { where('data_of_month = ?', Date.today.beginning_of_month)}
  scope :specific_month_data, -> (first_day_of_month) { where('data_of_month = ?', first_day_of_month)}
  scope :available_months, -> { select('data_of_month').group('data_of_month').order(data_of_month: :desc).limit(5) }

  scope :order_by_ttf_contribution, -> { where('ttf_contribution IS NOT NULL AND ttf_contribution > 0').order(ttf_contribution: :desc).limit(100) }
  scope :order_by_monthly_contribution, -> { where('monthly_contribution IS NOT NULL AND monthly_contribution > 0').order(monthly_contribution: :desc).limit(100) }
  scope :order_by_discovery_contribution, -> { where('discovery_contribution IS NOT NULL AND discovery_contribution > 0').order(discovery_contribution: :desc).limit(100) }

  def self.until_date
    Date.today
  end

  def self.find_or_create_by_github_and_data_of_month(github_user, data_of_month)
    find_or_create_by(github_user: github_user, data_of_month: data_of_month)
  end

  # 获取仓库维度的数据，用于 TTF 总榜及月度榜
  def self.fetch_github_repo_statistics
    Sidekiq.logger.info("Begin to run fetch_github_repo_statistics")
    repo_urls = get_all_repo_urls

    repo_statistics = fetch_github_statistics_by_repo_url(repo_urls)
    Sidekiq.logger.info("repos: #{repo_statistics.to_json}")

    ttf_contributors = sum_contributors_by_repos(repo_statistics)
    Sidekiq.logger.info("ttf contribotors: #{ttf_contributors.to_json}")


    ttf_contributors.collect do |contributor|
      statistic_record = GitHubStatistic.find_or_create_by_github_and_data_of_month(
        contributor["github_login"], until_date.at_beginning_of_month)

      # 总榜贡献指数
      statistic_record.ttf_contribution = contributor["total"]

      # 月度榜贡献指数
      statistic_record.monthly_contribution = contributor["current_month_commit_count"]

      statistic_record.testerhome_user = contributor["testerhome_user"]
      statistic_record.updated_at = Time.now.utc
      statistic_record.save
    end

    Sidekiq.logger.info("Finish running fetch_github_repo_statistics")

  end


  def self.fetch_github_user_statistics
    Sidekiq.logger.info("Begin to run fetch_github_user_statistics")

    users = User.with_github

    users.map.with_index do |user, user_index|
      Sidekiq.logger.info("Fetch github user statistics progress: #{user_index+1}:#{users.size}")

      followers = get_url_data(github_user_api_url(user.github))["followers"]

      current_month_events = get_current_month_events(user.github)

      # 挖潜榜贡献指数
      if !followers.nil? and !current_month_events.nil?  # 确认接口均可以正常返回数据，才更新潜力榜指数
        statistic_record = GitHubStatistic.find_or_create_by_github_and_data_of_month(
            user.github, until_date.at_beginning_of_month)
        statistic_record.discovery_contribution = followers + current_month_events * 0.2
        statistic_record.testerhome_user = user.login
        statistic_record.updated_at = Time.now.utc
        statistic_record.save
      else
        Sidekiq.logger.warn("Fetch github data failed, do not update data")
      end
    end

    Sidekiq.logger.info("Finish running fetch_github_user_statistics")
  end



  # private methods

  def self.github_repo_stats_api_url(owner, repo)
    # 接口文档: https://developer.github.com/v3/repos/statistics/#get-contributors-list-with-additions-deletions-and-commit-counts
    # /repos/:owner/:repo/stats/contributors
    "https://api.github.com/repos/#{owner}/#{repo}/stats/contributors"
  end

  def self.github_repo_commits_api_url(owner, repo, begin_date, end_date, author, page: 1)
    # 接口文档: https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository
    # /repos/:owner/:repo/commits
    "https://api.github.com/repos/#{owner}/#{repo}/commits?author=#{author}&since=#{begin_date}&until=#{end_date}&page=#{page}"
  end

  def self.github_user_api_url(user_name)
    # 接口文档: https://developer.github.com/v3/users/
    # /users/:username
    "https://api.github.com/users/#{URI.escape(user_name)}"
  end

  def self.github_user_public_events_api_url(user_name, page: 1)
    # 接口文档: https://developer.github.com/v3/activity/events/#list-public-events-performed-by-a-user
    # /users/:username/events/public
    "https://api.github.com/users/#{URI.escape(user_name)}/events/public?page=#{page}"
  end

  def self.github_org_repos_api_url(org, page: 1)
    # 接口文档: https://developer.github.com/v3/repos/#list-organization-repositories
    # /orgs/:org/repos
    "https://api.github.com/orgs/#{org}/repos?page=#{page}"
  end


  # 请求指定 url 的便利方法，带有自动重试。遇到 http error 会根据 skip_http_error 决定是抛异常还是返回空 dict 。默认返回空 dict
  def self.get_url_data(url, max_retry: 15, delay_seconds: 2, skip_http_error: true, init_sleep_seconds: 1)
    json = {}

    Sidekiq.logger.info("Begin to request url #{url}")

    begin
      # 每个请求之间的固定时间间隔，避免间隔太短触发 github 请求上限
      sleep(init_sleep_seconds)
      retries ||= 0

      # 由于前面已经写了域名，所以不用每次都写全路径，传 path 即可。
      path = url.gsub("https://api.github.com", "")

      conn = Faraday.new("https://api.github.com")
      conn.basic_auth(Setting.github_token, Setting.github_secret)
      resp = conn.get(path)

      if resp.status == 200
        json = JSON.parse(resp.body)
      else
        # 返回 http status 错误码，直接抛异常无需重试
        status_error_msg = "Response status is not 200, it is '#{resp.status}'"
        Sidekiq.logger.warn("Skip http error while requesting #{url}: #{status_error_msg}")
        if skip_http_error
          return json
        else
          raise status_error_msg
        end
      end

    rescue Errno::ETIMEDOUT, Timeout::Error, Faraday::TimeoutError, Faraday::ConnectionFailed, Errno::ECONNREFUSED => e
      sleep(delay_seconds)

      # 请求接口次数比较多，稳定性不好保障，所以加上重试提高稳定性
      if (retries += 1) < max_retry
        Sidekiq.logger.info("Retrying the #{retries} time with delay seconds #{delay_seconds} because of error: #{e}")
        # 每次重试都增加一倍的时间间隔，更便于躲开不稳定时段
        delay_seconds += delay_seconds
        retry
      end

      error_msg = "Skip request because error occurs while requesting #{url}: #{e}"
      Sidekiq.logger.error(error_msg)
      raise error_msg
    end




    return json
  end




  def self.fetch_github_statistics_by_repo_url(repo_urls)
    repos = []

    repo_urls.map.with_index do |repo_url, repo_url_index|
      Sidekiq.logger.info("Fetch github statistics by repo url progress: #{repo_url_index+1}:#{repo_urls.size}")

      match_result = repo_url.match('https:\/\/github.com\/(?<repo_owner>[a-zA-Z].*)\/(?<repo_name>[a-zA-Z].*)\z')

      if match_result.nil?
        Sidekiq.logger.error("Invalid repo url: #{repo_url} ! It should contain owner and repo name like 'https://github.com/owner/repo_name'")
        next
      end

      repo_owner, repo_name = match_result.captures

      # 逐个获取原始数据
      github_contributors = get_url_data(github_repo_stats_api_url(repo_owner, repo_name))
      contributors = []

      github_contributors.collect do |github_contributor|
        # author 有可能为 null ，需要略过
        if github_contributor == nil or github_contributor["author"] == nil
          next
        end
        # 做个适配，后续即使 github api 数据结构有变化，通过这个地方适配即可
        contributor = {
            "github_login" => github_contributor["author"]["login"],
            "total" => github_contributor["total"],
            "is_testerhome_user" => false,
            "testerhome_user" => nil,
            "current_month_commit_count" => 0
        }

        # 给 contributors 加上 is_testerhome_user 标签
        testerhome_user = User.find_by_github(contributor["github_login"])
        if testerhome_user
          contributor["is_testerhome_user"] = true
          contributor["testerhome_user"] = testerhome_user.login
        end

        # 给 contributors 加上当月提交数统计数据。获取最多25页的数据（实际 github 支持更多页数，但基本上25页够用了）
        (1..25).collect do |page|
          url = github_repo_commits_api_url(
              repo_owner,
              repo_name,
              until_date.beginning_of_month.strftime('%Y-%m-%dT%H:%M:%SZ'),
              until_date.strftime('%Y-%m-%dT%H:%M:%SZ'),
              contributor["github_login"],
              page: page
          )
          current_month_commits = get_url_data(url)

          if current_month_commits.size == 0
            # 已经到了没有数据的页，无需继续往下遍历
            break
          end

          contributor["current_month_commit_count"] += current_month_commits.size
        end

        contributors << contributor
      end

      repo = {
          "name" => "#{repo_owner}/#{repo_name}",
          "url" => repo_url,
          "contributors" => contributors
      }

      repos << repo
    end

    repos
  end

  def self.sum_contributors_by_repos(repos)
    sum_contributors = []

    repos.map.with_index do |repo, repo_index|
      Sidekiq.logger.info("Sum contributors by repos progress: #{repo_index+1}:#{repos.size}")
      repo["contributors"].collect do |repo_contributor|
        # 寻找是否已有同名的贡献者
        exist_sum_contributors = sum_contributors.select {|x| x["github_login"] == repo_contributor["github_login"] }
        if exist_sum_contributors.size > 0
          # 已存在，需要累加统计数据
          exist_sum_contributors[0]["total"] += repo_contributor["total"]
          exist_sum_contributors[0]["current_month_commit_count"] += repo_contributor["current_month_commit_count"]
        else
          # 不存在，需要新增元素
          sum_contributor = {
              "github_login" => repo_contributor["github_login"],
              "total" => repo_contributor["total"],
              "is_testerhome_user" => repo_contributor["is_testerhome_user"],
              "testerhome_user" => repo_contributor["testerhome_user"],
              "current_month_commit_count" => repo_contributor["current_month_commit_count"]
          }

          sum_contributors << sum_contributor
        end
      end
    end

    # 按 commit 总次数，从多到少排序
    sum_contributors.sort! { |a, b| b["total"] <=> a["total"] }

    sum_contributors
  end

  def self.get_all_repo_urls
    repo_urls = []
    Setting.github_stats_repos_list.collect do |github_url|

      org_match_result = github_url.match('https:\/\/github.com\/(?<org>[a-zA-Z\-]*)\z')

      if org_match_result.nil?
        repo_urls << github_url
        next
      end

      org = org_match_result.captures[0]
      repo_urls = repo_urls | get_repos_urls_by_org(org)
    end

    repo_urls
  end

  def self.get_repos_urls_by_org(org)
    org_repos_urls = []

    # 每页只展示30个，最多取50页基本足够了
    (1..50).collect do |page|
      repos = get_url_data(github_org_repos_api_url(org, page: page))
      Sidekiq.logger.info("Page is #{page}, repos size is #{org_repos_urls.size}")
      if repos.empty?
        return org_repos_urls
      end

      repos.collect do |repo|
        org_repos_urls << repo["html_url"]
      end

    end

    org_repos_urls
  end




  def self.get_current_month_events(github_login)
    current_month_events = 0

    # github 合计存储10页，每页30个事件，且只会存储最近90天的事件
    (1..10).collect do |page|
      begin
        events = get_url_data(github_user_public_events_api_url(github_login, page: page), skip_http_error: false)
      rescue OpenURI::HTTPError => e
        # 返回 nil 表示网络数据请求有问题，数据无效
        return nil
      end

      if events.empty?
        return current_month_events
      end

      events.collect do |event|
        if Time.parse(event["created_at"]) < until_date.beginning_of_month
          # 当出现本月第一天之前产生的事件时，由于返回数据本身是时间倒序，因此可以直接返回累计数据
          return current_month_events
        end
        current_month_events += 1
      end
    end

    current_month_events
  end


end
