# frozen_string_literal: true

class PhotosController < ApplicationController
  load_and_authorize_resource

  def create
    if params[:file].blank?
      render json: { ok: false }, status: 400
      return
    end

    # 浮动窗口上传
    @photo = Photo.new(image: params[:file], user_id: current_user.id)
    if @photo.save
      render json: { ok: true, url: @photo.image.url(:large) }
    else
      render json: { ok: false, message: @photo.errors.full_messages }, status: 400
    end
  end
end
