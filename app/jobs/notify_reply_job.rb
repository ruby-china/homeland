# frozen_string_literal: true

class NotifyReplyJob < ApplicationJob
  queue_as :notifications

  def perform(reply_id)
    reply = Reply.find_by_id(reply_id)
    return if reply.blank?
    return if reply.system_event?

    default_note = reply.default_notification
    all_records = []
    reply.notification_receiver_ids.each do |user_id|
      all_records << default_note.merge(user_id: user_id)
    end

    all_records.each_slice(100) do |records|
      Notification.insert_all(records)
    end

    # Touch realtime_push_to_client
    reply.notification_receiver_ids.each do |user_id|
      n = Notification.where(user_id: user_id).last
      n.realtime_push_to_client if n.present?
    end
    reply.broadcast_to_client
  end
end
