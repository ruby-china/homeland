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
  
  after_create :realtime_push_to_client
  after_destroy :realtime_push_to_client
  
  def realtime_push_to_client
    if self.user
      FayeClient.send("/notifications_count/#{self.user_id}", :count => self.user.notifications.unread.count)
    end
  end


  def anchor
    "notification-#{id}"
  end
end
