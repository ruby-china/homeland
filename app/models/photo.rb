class Photo < ApplicationRecord
  belongs_to :user

  validates_presence_of :image

  # 封面图
  mount_uploader :image, PhotoUploader
end
