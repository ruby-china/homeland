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
        redirect_to admin_plugins_path, notice: "Plugin was install successfully, if page not refresh, please refresh it."
      else
        redirect_to admin_plugins_path, alert: "Plugin was install error, please check the zip to determine that is correct."
      end
    end

    def destroy
      if @plugin.destroy
        Homeland.reboot
        redirect_to admin_plugins_path, notice: "Plugn was uninstall successfully."
      else
        redirect_to admin_plugins_path, alert: "Plugn was uninstall error."
      end
    end

    private

    def set_plugin
      @plugin = Homeland.find_plugin(params[:id])
    end
  end
end
