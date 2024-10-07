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
        redirect_to admin_plugins_path, notice: t("views.admin.plugin_was_install_success")
      else
        redirect_to admin_plugins_path, alert: t("views.admin.plugin_was_install_error")
      end
    end

    def destroy
      if @plugin.destroy
        Homeland.reboot
        redirect_to admin_plugins_path, notice: t("views.admin.plugn_was_uninstall_successfully")
      else
        redirect_to admin_plugins_path, alert: t("views.admin.plugn_was_uninstall_error")
      end
    end

    private

    def set_plugin
      @plugin = Homeland.find_plugin(params[:id])
    end
  end
end
