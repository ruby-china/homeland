# coding: utf-8  
class PhotosController < ApplicationController
  
  load_and_authorize_resource
   
  def index
    @photos = Photo.all
  end

  def show
    @photo = Photo.find(params[:id])
  end
  
  def tiny_new
    @photo = Photo.new
    render :layout => "window"
  end

  def new
    @photo = Photo.new
  end

  def edit
    @photo = current_user.photos.find(params[:id])
  end

  def create
    # 浮动窗口上传    
    if params[:tiny] == '1'
      photos = []
      if !params[:image1].blank?
        photo1 = Photo.new
        photo1.image = params[:image1]
        photos << photo1
      end
      if !params[:image2].blank?
        photo2 = Photo.new
        photo2.image = params[:image2]
        photos << photo2
      end
      if !params[:image3].blank?
        photo3 = Photo.new
        photo3.image = params[:image3]
        photos << photo3
      end
    
      @photos = []
      photos.each  do |p|
        p.user_id = current_user.id
        if not p.save
          logger.error("/photos/create save faield: #{p.errors.full_messages.join('\n')}")
          redirect_to(tiny_new_photos_path, :notice => p.errors.full_messages.join("<br />"))
          return
        else
          @photos << p
        end
      end
      render :action => :create, :layout => "window"
    else
      # 普通上传
      @photo = Photo.new(params[:photo])
      if @photo.save
        redirect_to(@photo, :notice => 'Photo was successfully created.')
      else
        return render :action => "new"
      end
    end 
  end

  def update
    @photo = current_user.photos.find(params[:id])
    
    if @photo.update_attributes(params[:photo])
      redirect_to(@photo, :notice => 'Photo was successfully updated.')
    else
      render :action => "edit"
    end
  end


  def destroy
    @photo = current_user.photos.find(params[:id])
    @photo.destroy

    redirect_to(photos_url)
  end
end
