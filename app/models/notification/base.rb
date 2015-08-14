module Notification
  class Base
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::BaseModel

    store_in collection: 'notifications'

    field :read, default: false
    belongs_to :user

    index read: 1
    index user_id: 1, read: 1

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
