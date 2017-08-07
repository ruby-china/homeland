module Api
  module V3
    class PhotosController < Api::V3::ApplicationController
      before_action :doorkeeper_authorize!

      # 上传图片,请使用 Multipart 的方式提交图片文件
      #
      # POST /api/v3/photos
      #
      # @param file - 文件信息, [required]
      #
      # == returns
      # - image_url 图片 URL
      def create
        requires! :file

        @photo = Photo.new
        @photo.image   = params[:file]
        @photo.user_id = current_user.id
        @photo.save!
      end
    end
  end
end
