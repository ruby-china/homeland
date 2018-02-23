# frozen_string_literal: true

module Admin
  class PhotosController < Admin::ApplicationController
    before_action :set_photo, only: %i[show destroy]

    def index
      @photos = Photo.recent.includes(:user).page(params[:page])
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
