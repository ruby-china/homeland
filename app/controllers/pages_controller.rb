# coding: utf-8
class PagesController < ApplicationController

  authorize_resource :page

  before_filter :init_base_breadcrumb
  before_filter :set_menu_active

  def index
    set_seo_meta("Wiki")
    drop_breadcrumb("索引")

    fresh_when(:etag => [SiteConfig.wiki_index_html])
  end

  def recent
    @pages = Page.recent.paginate(:page => params[:page], :per_page => 30)
    set_seo_meta t("pages.wiki_index")
    drop_breadcrumb t("common.index")

    fresh_when(:etag => [@pages])
  end

  def show
    @page = Page.find_by_slug(params[:id])
    if @page.nil?
      if current_user
        redirect_to new_page_path(:title => params[:id]), :notice => "Page not Found, Please create a new page"
      else
        render_404
      end
    else
      set_seo_meta("#{@page.title} - Wiki")
      drop_breadcrumb("查看 #{@page.title}")
      fresh_when(:etag => [@page,@page.comments_count])
    end
  end

  def comments
    @page = Page.find_by_slug(params[:id])
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
    set_seo_meta t("pages.edit_wiki_page")
    drop_breadcrumb t("common.edit")
  end

  def create
    @page = Page.new(page_params)
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
    @page.version_enable = true
    @page.user_id = current_user.id

    if @page.update_attributes(page_params)
      redirect_to page_path(@page.slug), notice: t("common.update_success")
    else
      render action: "edit"
    end
  end

  def preview
    render :text => MarkdownConverter.convert( params[:body] )
  end

protected

  def set_menu_active
    @current = @current = ['/wiki']
  end

  def init_base_breadcrumb
    drop_breadcrumb("Wiki", pages_path)
  end

  def page_params
    params.require(:page).permit(:title, :body, :slug, :change_desc)
  end
end
