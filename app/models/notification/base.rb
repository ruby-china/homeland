class Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::BaseModel

  store_in :notifications

  field :read, :default => false

  scope :unread, where(:read => false)

  belongs_to :user

  def anchor
    "notification-#{id}"
  end
end
