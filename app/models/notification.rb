# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
  self.table_name = 'new_notifications'

  include Notifications::Model

  self.per_page = 20

  after_create :realtime_push_to_client
  after_update :realtime_push_to_client

  def realtime_push_to_client
    if user
      self.class.realtime_push_to_client(user)
      PushJob.perform_later(user_id, apns_note)
    end
  end

  def self.realtime_push_to_client(user)
    ActionCable.server.broadcast "notifications_count/#{user.id}", { count: Notification.unread_count(user) }
  end

  def apns_note
    @note ||= { alert: notify_title, badge: Notification.unread_count(user) }
  end

  def notify_title
    ''
  end

  def self.notify_follow(user_id, follower_id)
    opts = {
      notify_type: 'follow',
      user_id: user_id,
      actor_id: follower_id
    }
    return if Notification.where(opts).count > 0
    Notification.create opts
  end
end
