module Admin
  class StatsController < Admin::ApplicationController
    # GET /stats
    # params:
    # model - Model 名称
    # by - day, week, month
    def index
      date_from = case params[:by]
                  when 'month' then 12.months.ago.beginning_of_month.to_date
                  when 'week' then 6.months.ago.beginning_of_month.to_date
                  else 30.days.ago.beginning_of_month.to_date
                  end
      res = {}
      klass = params[:model].camelize.constantize
      group_cmd = case params[:by]
                  when 'day' then "date(created_at at time zone 'CST')"
                  when 'week' then "date_trunc('week', created_at)"
                  else "date_trunc('month', created_at)"
                  end
      results = klass.unscoped.where('created_at >= ? and created_at <= ?', date_from, Date.current)
                              .group("date")
                              .select("#{group_cmd} AS date, count(id) AS count").all
      render json: results.as_json
    end
  end
end