# frozen_string_literal: true

module Admin
  class StatsController < Admin::ApplicationController
    # GET /stats
    # params:
    # model - Model 名称
    # by - day, week, month
    def index
      result = {model: params[:model]}
      result[:count] = klass.unscoped.async_count.value
      result[:week_count] = klass.unscoped.where("created_at >= ?", Date.today.beginning_of_week).async_count.value
      result[:month_count] = klass.unscoped.where("created_at >= ?", Date.today.beginning_of_month).async_count.value
      render json: result.as_json
    end

    def klass
      params[:model].camelize.safe_constantize
    end
  end
end
