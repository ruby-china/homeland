# frozen_string_literal: true

class GitHubStatisticsController < ApplicationController
  include GitHubStatistic::ClassMethods

  def index
    @github_statistics = GitHubStatistic.all
    @available_months = GitHubStatistic.available_months

    month = nil

    # 参数校验
    begin
      month = DateTime.parse(params[:month]).strftime("%Y-%m-%d")
    rescue
      # 什么都不用做，直接忽略错误当 month 参数不存在即可
    end

    if month
      @github_ttf_contributors = GitHubStatistic.specific_month_data(month).order_by_ttf_contribution
      @github_monthly_conributors = GitHubStatistic.specific_month_data(month).order_by_monthly_contribution
      @github_discovery_contributor = GitHubStatistic.specific_month_data(month).order_by_discovery_contribution
      @data_of_month = month
    else
      @github_ttf_contributors = GitHubStatistic.current_month_data.order_by_ttf_contribution
      @github_monthly_conributors = GitHubStatistic.current_month_data.order_by_monthly_contribution
      @github_discovery_contributor = GitHubStatistic.current_month_data.order_by_discovery_contribution
    end
  end
end
