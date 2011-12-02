# coding: utf-8
class PagesController < ApplicationController

  authorize_resource :page
  
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
    if !@page
      if !current_user
        render_404
        return
      else
        redirect_to new_page_path(:title => params[:id]), :notice => "Page not Found, Please create a new page"
        return
      end
    end
    set_seo_meta("#{@page.title} - Wiki")
    drop_breadcrumb("查看 #{@page.title}")
  end

  def new
    @page = Page.new
    @page.slug = params[:title]
    set_seo_meta t("pages.new_wiki_page")
    drop_breadcrumb t("pages.new_wiki_page")
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  def edit
    @page = Page.find(params[:id])
    
    authorize! :edit, @page
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
    
    authorize! :update, @page
    
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
end
