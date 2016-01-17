module Notification
  class Base < ActiveRecord::Base
    include BaseModel

    self.table_name = 'notifications'

    belongs_to :user

    scope :unread, -> { where(read: false) }

    after_create :realtime_push_to_client
    after_update :realtime_push_to_client

    def realtime_push_to_client
      if user
        hash = notify_hash
        hash[:count] = user.notifications.unread.count
        MessageBus.publish "/notifications_count/#{user.temp_access_token}", hash
      end
    end

    def content_path
      ''
    end

    def actor
      nil
    end

    def anchor
      "notification-#{id}"
    end
  end
end
