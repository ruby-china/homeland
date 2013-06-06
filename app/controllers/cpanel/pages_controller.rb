# coding: utf-8
class Cpanel::PagesController < Cpanel::ApplicationController

  def index
    @pages = Page.unscoped.desc(:_id).paginate :page => params[:page], :per_page => 30

  end

  def show
    @page = Page.unscoped.find(params[:id])

  end

  def new
    @page = Page.new

  end

  def edit
    @page = Page.unscoped.find(params[:id])
  end

  def create
    @page = Page.new(params[:page].permit!)

    if @page.save
      redirect_to(cpanel_pages_path, :notice => 'Page was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @page = Page.unscoped.find(params[:id])
    @page.title = params[:page][:title]
    @page.body = params[:page][:body]
    @page.slug = params[:page][:slug]
    @page.locked = params[:page][:locked]
    @page.user_id = current_user.id

    if @page.save
      redirect_to(cpanel_pages_path, :notice => 'Page was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @page = Page.unscoped.find(params[:id])
    @page.destroy

    redirect_to(cpanel_pages_path)
  end
end
