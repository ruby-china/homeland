# coding: UTF-8
class Cpanel::LocationsController < Cpanel::ApplicationController

  def index
    @locations = Location.hot.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def create
    @location = Location.new(params[:location].permit!)

    respond_to do |format|
      if @location.save
        format.html { redirect_to(cpanel_locations_path, :notice => 'Location 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end

  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location].permit!)
        format.html { redirect_to(cpanel_locations_path, :notice => 'Location 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(cpanel_locations_path,:notice => "删除成功。") }
      format.json
    end
  end
end
