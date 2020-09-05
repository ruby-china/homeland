# frozen_string_literal: true
class TipOff < ApplicationRecord
  include SoftDelete

  belongs_to :reporter, class_name: "User"
  belongs_to :content_author, class_name: "User", optional: true
  belongs_to :follower, class_name: "User", optional: true

  validates :content_url, :reporter_email, :tip_off_type, :body, presence: true

  scope :by_reporter, -> (userId) { where(reporter_id: userId) }
  scope :by_content_author, -> (userId) { where(content_author: userId) }
end
