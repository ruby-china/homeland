# encoding: utf-8
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

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :small do
    process :resize_to_limit => [100, nil]
  end
  
  version :normal do
    process :resize_to_limit => [680, nil]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  def filename
    "#{model.id}.jpg" if original_filename
  end

end
