module Admin
  class PhotosController < Admin::ApplicationController
    before_action :set_photo, only: [:show, :edit, :update, :destroy]

    def index
      @photos = Photo.recent.includes(:user).paginate(page: params[:page], per_page: 20)
    end

    def show
    end

    def new
      @photo = Photo.new
    end

    def edit
    end

    def create
      @photo = Photo.new(params[:photo].permit!)
      @photo.user_id = current_user.id
      if @photo.save
        redirect_to(admin_photo_path(@photo), notice: 'Photo was successfully created.')
      else
        render action: 'new'
      end
    end

    def update
      if @photo.update_attributes(params[:photo].permit!)
        redirect_to(admin_photo_path(@photo), notice: 'Photo was successfully updated.')
      else
        render action: 'edit'
      end
    end

    def destroy
      @photo.destroy
      redirect_to(admin_photos_url)
    end

    private

    def set_photo
      @photo = Photo.find(params[:id])
    end
  end
end
