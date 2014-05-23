# coding: utf-8
class PhotosController < ApplicationController
  load_and_authorize_resource

  def create
    # 浮动窗口上传
    @photo = Photo.new
    @photo.image = params[:Filedata]
    @photo.user_id = current_user.id
    @photo.save
    render text: @photo.image.url
  end
end
