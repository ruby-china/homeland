# frozen_string_literal: true

module Admin
  class StatsController < Admin::ApplicationController
    # GET /stats
    # params:
    # model - Model 名称
    # by - day, week, month
    def index
      result = {model: params[:model]}
      result[:count] = klass.unscoped.count
      result[:week_count] = klass.unscoped.where("created_at >= ?", Date.today.beginning_of_week).count
      result[:month_count] = klass.unscoped.where("created_at >= ?", Date.today.beginning_of_month).count
      render json: result.as_json
    end

    def klass
      params[:model].camelize.safe_constantize
    end
  end
end
