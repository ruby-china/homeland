# coding: utf-8
class Cpanel::PageVersionsController < Cpanel::ApplicationController

  before_filter :set_menu_active

  def index
    @page = Page.find(params[:page_id])
    @page_versions = @page.versions.desc(:version).paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @page = Page.find(params[:page_id])
    @page_version = @page.versions.find(params[:id])
  end

  def revert
    @page = Page.find(params[:page_id])
    @page_version = @page.versions.find(params[:id])
    if @page.revert_version(@page_version.version)
      redirect_to cpanel_page_versions_path(params[:page_id]), :notice => "Wiki 内容已经撤销到了版本 #{@page_version.version}"
    else
      redirect_to cpanel_page_versions_path(params[:page_id]), :alert => "版本撤销失败，原因: #{@page.errors.full_messages.join("<br />")}"
    end
  end

  protected

  def set_menu_active
    @current = @current = ['/cpanel/pages']
  end

end
