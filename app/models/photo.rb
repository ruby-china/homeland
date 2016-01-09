class Photo < ActiveRecord::Base
  include BaseModel

  belongs_to :user

  ACCESSABLE_ATTRS = [:image]

  # 封面图
  mount_uploader :image, PhotoUploader
end
