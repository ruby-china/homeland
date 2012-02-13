# encoding: utf-8
require "digest/md5"
require 'carrierwave/processing/mini_magick'
class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :grid_fs

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "photo/#{version_name}.jpg"
  end

  process :resize_to_limit => [680, nil]

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  def filename
    if super.present?
      ext = File.extname(original_filename)
      # NOTE: 这里的到的图片是裁减过后的图片 MD5，也就是说，只有当原图小于裁减范围的时候，md5 才会保持和原始图片 md5 一致，而达到覆盖的目的
      fname = Digest::MD5.hexdigest(self.read)
      @name ||= "#{fname}#{ext}"
    end
  end

end
