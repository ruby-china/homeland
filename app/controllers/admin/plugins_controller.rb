# frozen_string_literal: true

module Admin
  class PluginsController < Admin::ApplicationController
    before_action :set_plugin, only: %i[show destroy]
    def index
    end

    def show
    end

    def create
      tmp = params[:file].tempfile
      FileUtils.move tmp.path, Rails.root.join("plugins")
      basename = File.basename(tmp.path)
      zip_filename = Rails.root.join("plugins", basename)
      `cd plugins; unzip -o #{zip_filename}`
      Homeland.reboot
      redirect_to admin_plugins_path, notice: "插件安装成功，如列表没有更新，请再次刷新页面。"
    ensure
      FileUtils.rm_f(zip_filename)
    end

    def destroy
      if @plugin.uninstallable?
        FileUtils.rm_rf(@plugin.source_path)
      end
      Homeland.reboot
      redirect_to admin_plugins_path, notice: "卸载成功，如列表没有更新，请再次刷新页面"
    end

    private

      def set_plugin
        @plugin = Homeland.find_plugin(params[:id])
      end
  end
end
