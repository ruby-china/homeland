# frozen_string_literal: true

module Admin
  class DashboardsController < Admin::ApplicationController
    def index
      @recent_topics = Topic.recent.limit(5)
    end

    def reboot
      Homeland.reboot
      flash[:alert] = t("admin.reboot_successfully")
      redirect_referrer_or_default admin_root_path
    end
  end
end
