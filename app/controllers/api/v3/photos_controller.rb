module Api
  module V3
    class PhotosController < ApplicationController
      before_action :doorkeeper_authorize!

      ##
      # 上传图片,请使用 Multipart 的方式提交图片文件
      #
      # POST /api/v3/photos
      #
      # params:
      #   file - 文件信息, [required]
      #
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
