# frozen_string_literal: true

module Admin
  class PhotosController < Admin::ApplicationController
    before_action :set_photo, only: %i[show destroy]

    def index
      @photos = Photo.recent.includes(:user)
      if params[:login].present?
        u = User.find_by_login(params[:login])
        @photos = @photos.where("user_id = ?", u&.id)
      end
      @photos = @photos.page(params[:page])
    end

    def destroy
      @photo.destroy

      respond_to do |format|
        format.js
        format.html { redirect_to(admin_photos_url) }
      end
    end

    private

    def set_photo
      @photo = Photo.find(params[:id])
    end
  end
end
