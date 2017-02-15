class PagesController < ApplicationController
  require_module_enabled! :wiki
  authorize_resource :page
  before_action :set_page, only: [:show, :edit, :update, :destroy, :comments]

  etag { Setting.wiki_sidebar_html }

  def index
    fresh_when(Setting.wiki_index_html)
  end

  def recent
    @pages = Page.recent.paginate(page: params[:page], per_page: 30)
    fresh_when(@pages)
  end

  def show
    if @page.blank?
      if current_user.blank?
        render_404
        return
      end

      redirect_to new_page_path(title: params[:id]), notice: 'Page not Found, Please create a new page'
      return
    end

    @page.hits.incr(1)
    fresh_when(@page)
  end

  def comments
    render_404 if @page.blank?
  end

  def new
    @page = Page.new
    @page.slug = params[:title]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  def edit
  end

  def create
    @page = Page.new(page_params)
    @page.user_id = current_user.id
    @page.version_enable = true

    if @page.save
      redirect_to page_path(@page.slug), notice: t('common.create_success')
    else
      render action: 'new'
    end
  end

  def update
    @page.version_enable = true
    @page.user_id = current_user.id

    if @page.update(page_params)
      redirect_to page_path(@page.slug), notice: t('common.update_success')
    else
      render action: 'edit'
    end
  end

  def preview
    render plain: Homeland::Markdown.call(params[:body])
  end

  protected

  def set_page
    @page = Page.find_by_slug(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :body, :slug, :change_desc)
  end
end
