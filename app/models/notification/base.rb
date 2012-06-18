class Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::BaseModel

  store_in :collection => 'notifications'

  field :read, :default => false
  belongs_to :user

  index :read => 1
  index :user_id => 1, :read => 1

  scope :unread, where(:read => false)


  def anchor
    "notification-#{id}"
  end
end
