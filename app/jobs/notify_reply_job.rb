# frozen_string_literal: true

class NotifyReplyJob < ApplicationJob
  queue_as :notifications

  def perform(reply_id)
    reply = Reply.find_by_id(reply_id)
    return if reply.blank?
    return if reply.system_event?
    topic = Topic.find_by_id(reply.topic_id)
    return if topic.blank?

    notification_receiver_ids = reply.notification_receiver_ids

    # 私有组织仅组内消息接收者可收到消息
    if topic.private_org
      notification_receiver_ids = reply.private_org_notification_receiver_ids
    end

    # 仅作者可见的情况，回复消息会推送给帖子的作者
    if reply.exposed_to_author_only?
      notification_receiver_ids = []
      if reply.user_id != topic.user_id
        notification_receiver_ids = [topic.user_id]
      end
    end

    Notification.bulk_insert(set_size: 100) do |worker|
      notification_receiver_ids.each do |uid|
        logger.debug "Post Notification to: #{uid}"
        note = reply.send(:default_notification).merge(user_id: uid)
        worker.add(note)
      end
    end

    # Touch realtime_push_to_client
    notification_receiver_ids.each do |uid|
      n = Notification.where(user_id: uid).last
      n.realtime_push_to_client if n.present?
    end
    reply.broadcast_to_client
  end
end
