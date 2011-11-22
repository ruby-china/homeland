# coding: utf-8
class PagesController < ApplicationController
  before_filter :check_lock, :only => [:edit, :update]
  before_filter :require_user, :only => [:new, :edit, :create, :update]
  before_filter :check_permissions, :only => [:new, :edit, :create, :update]
  def index
    set_seo_meta("Wiki")
  end
  
  def recent
    @pages = Page.recent.paginate(:page => params[:page], :per_page => 30)
    set_seo_meta("Wiki 目录")
  end

  def show
    @page = Page.find_by_slug(params[:id])
    if not @page
      render_404
    end
    set_seo_meta("#{@page.title} - Wiki")
  end

  def new
    @page = Page.new
    set_seo_meta("创建 Wiki 页面")
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  def edit
    @page = Page.find(params[:id])
    set_seo_meta("修改 Wiki 页面")
  end

  def create
    @page = Page.new(params[:page])
    @page.user_id = current_user.id
    @page.version_enable = true

    if @page.save
      redirect_to page_path(@page.slug), notice: '页面创建成功。'
    else
      render action: "new"
    end
  end

  def update
    @page = Page.find(params[:id])
    params[:page][:version_enable] = true
    params[:page][:user_id] = current_user.id
    
    if @page.update_attributes(params[:page])
      redirect_to page_path(@page.slug), notice: '页面更新成功。'
    else
      render action: "edit"
    end
  end
  
  private
    def check_lock
      @page = Page.find(params[:id])
      if @page.locked
        if !current_user or !Setting.admin_emails.include?(current_user.email)
          redirect_to page_path(@page.slug), alert: "抱歉，此页面已被锁定，只能管理员才能修改。"
          return
        end
      end
    end
    
    def check_permissions
      if not current_user.wiki_editor?
        render_403
        return false
      end
      true
    end
end
