# frozen_string_literal: true

class NotifyReplyJob < ApplicationJob
  queue_as :notifications

  def perform(reply_id)
    reply = Reply.find_by_id(reply_id)
    return if reply.blank?
    return if reply.system_event?

    Notification.bulk_insert(set_size: 100) do |worker|
      reply.notification_receiver_ids.each do |uid|
        logger.debug "Post Notification to: #{uid}"
        note = reply.send(:default_notification).merge(user_id: uid)
        worker.add(note)
      end
    end

    # Touch realtime_push_to_client
    reply.notification_receiver_ids.each do |uid|
      n = Notification.where(user_id: uid).last
      n.realtime_push_to_client if n.present?
    end
    reply.broadcast_to_client
  end
end
