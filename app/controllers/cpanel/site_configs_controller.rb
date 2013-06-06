# coding: utf-8
class Cpanel::SiteConfigsController < Cpanel::ApplicationController

  def index
    @site_configs = SiteConfig.desc(:_id)
  end

  def edit
    @site_config = SiteConfig.find(params[:id])
  end

  def update
    @site_config = SiteConfig.find(params[:id])

    if @site_config.update_attributes(params[:site_config].permit!)
      redirect_to edit_cpanel_site_config_path(params[:id]), notice: "保存成功."
    else
      render action: "edit"
    end
  end

end
