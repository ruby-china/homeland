class Photo < ActiveRecord::Base
  include BaseModel
  belongs_to :user

  validates_presence_of :image

  # 封面图
  mount_uploader :image, PhotoUploader
end
