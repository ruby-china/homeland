# coding: utf-8
class PagesController < ApplicationController
  before_filter :check_lock, :only => [:edit, :update]
  before_filter :require_user, :only => [:new, :edit, :create, :update]
  before_filter :check_permissions, :only => [:new, :edit, :create, :update]
  before_filter :init_base_breadcrumb
  before_filter :set_menu_active
  
  def index
    set_seo_meta("Wiki")
    drop_breadcrumb("索引")
  end
  
  def recent
    @pages = Page.recent.paginate(:page => params[:page], :per_page => 30)
    set_seo_meta t("pages.wiki_index")
    drop_breadcrumb t("common.index")
  end

  def show
    @page = Page.find_by_slug(params[:id])
    if not @page
      render_404
    end
    set_seo_meta("#{@page.title} - Wiki")
    drop_breadcrumb("查看")
  end

  def new
    @page = Page.new
    set_seo_meta t("pages.new_wiki_page")
    drop_breadcrumb t("pages.new_wiki_page")
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  def edit
    @page = Page.find(params[:id])
    set_seo_meta t("pages.edit_wiki_page")
    drop_breadcrumb t("common.edit")
  end

  def create
    @page = Page.new(params[:page])
    @page.user_id = current_user.id
    @page.version_enable = true

    if @page.save
      redirect_to page_path(@page.slug), notice: t("common.create_success")
    else
      render action: "new"
    end
  end

  def update
    @page = Page.find(params[:id])
    params[:page][:version_enable] = true
    params[:page][:user_id] = current_user.id
    
    if @page.update_attributes(params[:page])
      redirect_to page_path(@page.slug), notice: t("common.update_success")
    else
      render action: "edit"
    end
  end
  
  protected
  
  def set_menu_active
    @current = @current = ['/wiki']
  end
  
  def init_base_breadcrumb
    drop_breadcrumb("Wiki", pages_path)
  end

  private
    def check_lock
      @page = Page.find(params[:id])
      if @page.locked
        if !current_user or !Setting.admin_emails.include?(current_user.email)
          redirect_to page_path(@page.slug), alert: t("pages.wiki_page_lock_warning")
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
