# frozen_string_literal: true

# 通知
# @class NotificationSerializer
#
# == attributes
# - *id* [Integer] 编号
# - *type* [String] 通知类型
# - *read* [Boolean] 是否已读
# - *actor* {UserSerializer} 动作发起者
# - *mention_type* [String] 提及的数据类型 Topic, Reply
# - *created_at* [DateTime] 创建时间
# - *updated_at* [DateTime] 更新时间
json.cache! ["v2", notification] do
  json.call(notification, :id, :created_at, :updated_at)
  json.type notification.notify_type.classify
  json.read notification.read?
  json.actor do
    json.partial! "user", user: notification.actor
  end

  if notification.notify_type != "mention"
    json.mention_type nil
    json.mention nil
  else
    json.mention_type notification.target_type
    json.mention do
      if notification.target_type == "Topic"
        json.partial! "topic", topic: notification.target
      elsif notification.target_type == "Reply"
        json.partial! "reply", reply: notification.target
      end
    end
  end

  json.topic do
    if notification.notify_type == "topic" || notification.notify_type == "node_changed"
      json.partial! "topic", topic: notification.try(:target)
    elsif notification.notify_type == "topic_reply"
      json.partial! "topic", topic: notification.try(:second_target)
    elsif notification.notify_type == "mention"
      if notification.target_type == "Topic"
        json.partial! "topic", topic: notification.try(:target)
      elsif notification.target_type == "Reply"
        json.partial! "topic", topic: notification.try(:second_target)
      end
    end
  end

  if notification.notify_type == "topic_reply"
    json.reply do
      json.partial! "reply", reply: notification.try(:target)
    end
  end

  if notification.notify_type == "node_changed" && notification.try(:second_target)
    json.node do
      json.partial! "node", node: notification.try(:second_target)
    end
  end
end
