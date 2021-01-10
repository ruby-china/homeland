# frozen_string_literal: true

class Photo < ApplicationRecord
  belongs_to :user, optional: true

  mount_uploader :image, PhotoUploader
  after_commit :remove_image!, on: :destroy
end
