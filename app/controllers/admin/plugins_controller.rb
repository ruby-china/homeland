# frozen_string_literal: true

module Admin
  class PluginsController < Admin::ApplicationController
    before_action :set_plugin, only: %i[show destroy]
    def index
    end

    def show
    end

    def create
      if Homeland::Plugin.install(params[:file])
        Homeland.reboot
        redirect_to admin_plugins_path, notice: "插件安装成功，如列表没有更新，请再次刷新页面。"
      else
        redirect_to admin_plugins_path, alert: "插件安装失败，请检查 ZIP 包确定是否正确。"
      end
    end

    def destroy
      if @plugin.destroy
        Homeland.reboot
        redirect_to admin_plugins_path, notice: "卸载成功，如列表没有更新，请再次刷新页面"
      else
        redirect_to admin_plugins_path, alert: "卸载失败。"
      end
    end

    private

      def set_plugin
        @plugin = Homeland.find_plugin(params[:id])
      end
  end
end
