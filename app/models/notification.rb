# frozen_string_literal: true

# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
  self.table_name = "new_notifications"

  include Notifications::Model

  after_create :realtime_push_to_client
  after_update :realtime_push_to_client

  def realtime_push_to_client
    if user
      Notification.realtime_push_to_client(user)
      PushJob.perform_later(user_id, apns_note)
    end
  end

  def self.realtime_push_to_client(user)
    ActionCable.server.broadcast("notifications_count/#{user.id}", count: Notification.unread_count(user))
  end

  def apns_note
    @note ||= { alert: notify_title, badge: Notification.unread_count(user) }
  end

  def notify_title
    return "" if self.actor.blank?
    if notify_type == "topic"
      "#{self.actor.login} 创建了话题 《#{self.target.title}》"
    elsif notify_type == "topic_reply"
      "#{self.actor.login} 回复了话题 《#{self.second_target.title}》"
    elsif notify_type == "follow"
      "#{self.actor.login} 开始关注你了"
    elsif notify_type == "mention"
      "#{self.actor.login} 提及了你"
    elsif notify_type == "node_changed"
      "你的话题被移动了节点到 #{self.second_target.name}"
    else
      ""
    end
  end

  def self.notify_follow(user_id, follower_id)
    opts = {
      notify_type: "follow",
      user_id: user_id,
      actor_id: follower_id
    }
    return if Notification.where(opts).count > 0
    Notification.create opts
  end
end
