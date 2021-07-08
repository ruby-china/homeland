# frozen_string_literal: true

module Admin
  class SiteConfigsController < Admin::ApplicationController
    before_action :set_setting, only: %i[edit update]

    def index
      params[:scope] ||= "basic"

      @setting_groups = Setting.defined_fields.select { |field| !field[:readonly] }.group_by { |field| field[:scope] || :other }
      @scope = params[:scope].to_sym
      @settings = @setting_groups[params[:scope].to_sym] || []
    end

    def edit
    end

    def update
      if @site_config.value == setting_param[:value]
        return redirect_to admin_site_configs_path(scope: @scope)
      end

      @site_config.value = setting_param[:value].strip
      if @site_config.save
        if @site_config.require_restart?
          Setting.require_restart = true
        end

        redirect_to admin_site_configs_path(scope: @scope), notice: "Update successfully."
      else
        render "edit"
      end
    end

    def set_setting
      @site_config = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
      field = Setting.get_field(@site_config.var)
      @scope = field[:scope] || "basic"
    end

    private

    def setting_param
      params[:setting].permit!
    end
  end
end
