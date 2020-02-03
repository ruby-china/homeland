# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::ApplicationController
    def index
      @recent_topics = Topic.recent.limit(5)
    end

    def reboot
      Homeland.reboot
      redirect_to admin_root_path, alert: "已经发起了重启命令，Homeland 在后台异步重启，你可以刷新页面，通过服务启动时间变化来确定重启是否完成。"
    end
  end
end
