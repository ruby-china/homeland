class Photo < ActiveRecord::Base

  belongs_to :user

  ACCESSABLE_ATTRS = [:image]

  # 封面图
  mount_uploader :image, PhotoUploader
end
