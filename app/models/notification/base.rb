class Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  store_in :collection => 'notifications'

  field :read, :default => false
  belongs_to :user

  index :read => 1
  index :user_id => 1, :read => 1

  scope :unread, where(:read => false)
  
  after_create :realtime_push_to_client
  
  def realtime_push_to_client
    if self.user
      hash = self.notify_hash
      hash[:count] = self.user.notifications.unread.count
      FayeClient.send("/notifications_count/#{self.user.temp_access_token}", hash)
    end
  end
  
  def content_path
    ""
  end


  def anchor
    "notification-#{id}"
  end
end
