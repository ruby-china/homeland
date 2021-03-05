# frozen_string_literal: true

# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
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
    message = {count: Notification.unread_count(user)}
    ActionCable.server.broadcast("notifications_count/#{user.id}", message)
  end

  def apns_note
    @note ||= {alert: notify_title, badge: Notification.unread_count(user)}
  end

  def notify_title
    return "" if actor.blank?
    if notify_type == "topic"
      I18n.t("notifications.created_topic", actor: actor.login, target: target.title)
    elsif notify_type == "topic_reply"
      I18n.t("notifications.created_reply", actor: actor.login, target: second_target.title)
    elsif notify_type == "follow"
      I18n.t("notifications.followed_you", actor: actor.login)
    elsif notify_type == "mention"
      I18n.t("notifications.mentioned_you", actor: actor.login)
    elsif notify_type == "node_changed"
      I18n.t("notifications.node_changed", node: second_target.name)
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
