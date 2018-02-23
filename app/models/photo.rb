# frozen_string_literal: true

class Photo < ApplicationRecord
  belongs_to :user, optional: true

  validates_presence_of :image

  # 封面图
  mount_uploader :image, PhotoUploader
end
