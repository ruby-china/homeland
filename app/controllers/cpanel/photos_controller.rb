# coding: utf-8  
class Cpanel::PhotosController < Cpanel::ApplicationController
  # GET /photos
  # GET /photos.xml
  def index
    @photos = Photo.desc("id").paginate :page => params[:page], :per_page => 20
  end

  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = Photo.find(params[:id])
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.xml
  def create
    @photo = Photo.new(params[:photo])
    @photo.user_id = current_user.id
    if @photo.save
      redirect_to(cpanel_photo_path(@photo), :notice => 'Photo was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
      redirect_to(cpanel_photo_path(@photo), :notice => 'Photo was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    redirect_to(cpanel_photos_url)
  end
end
