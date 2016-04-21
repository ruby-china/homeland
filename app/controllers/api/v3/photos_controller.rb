module Api
  module V3
    class PhotosController < ApplicationController
      before_action :doorkeeper_authorize!

      def create
        requires! :file

        @photo = Photo.new
        @photo.image = params[:file]
        @photo.user_id = current_user.id
        @photo.save!
        render json: { image_url: @photo.image.url }, status: 201
      end
    end
  end
end
