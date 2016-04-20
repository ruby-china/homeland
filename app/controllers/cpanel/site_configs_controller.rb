module Cpanel
  class SiteConfigsController < ApplicationController
    before_action :get_setting, only: [:edit, :update]

    def index
      @site_configs = Setting.get_all
    end

    def edit
    end

    def update
      if @site_config.value != params[:setting][:value]
        @site_config.value = YAML.load(params[:setting][:value])
        @site_config.save
        redirect_to cpanel_site_configs_path, notice: '保存成功.'
      else
        redirect_to cpanel_site_configs_path
      end
    end

    def get_setting
      @site_config = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
      @site_config[:value] = Setting[params[:id]]
    end
  end
end
