# coding: utf-8
class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  field :image

  belongs_to :user

  ACCESSABLE_ATTRS = [:image]

  # 封面图
  mount_uploader :image, PhotoUploader

end
