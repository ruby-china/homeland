# encoding: utf-8
require 'carrierwave/processing/mini_magick'
class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :s3
  storage :grid_fs

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "avatar/#{version_name}.jpg"
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :small do
    process :resize_to_fill => [16, 16]
  end
  
  version :normal do
    process :resize_to_fill => [48, 48]
  end
  
  version :large do
    process :resize_to_fill => [80, 80]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  def filename
    "#{original_filename.length}.jpg" if original_filename
  end

end
