# coding: utf-8  
class Cpanel::PagesController < Cpanel::ApplicationController
  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.unscoped.desc(:_id).paginate :page => params[:page], :per_page => 30

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.unscoped.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.unscoped.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to(cpanel_pages_path, :notice => 'Page was successfully created.') }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.unscoped.find(params[:id])
    @page.title = params[:page][:title]
    @page.body = params[:page][:body]
    @page.slug = params[:page][:slug]
    @page.locked = params[:page][:locked]
    @page.user_id = current_user.id

    respond_to do |format|
      if @page.save
        format.html { redirect_to(cpanel_pages_path, :notice => 'Page was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.unscoped.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_pages_path) }
      format.xml  { head :ok }
    end
  end
end
