# coding: utf-8
class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :image

  belongs_to :user

  attr_protected :user_id

  # 封面图
  mount_uploader :image, PhotoUploader

end
