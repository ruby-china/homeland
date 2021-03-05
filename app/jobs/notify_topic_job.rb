# frozen_string_literal: true

class NotifyTopicJob < ApplicationJob
  queue_as :notifications

  def perform(topic_id)
    topic = Topic.find_by_id(topic_id)
    return if topic&.user.blank?

    follower_ids = topic.user.follow_by_user_ids
    return if follower_ids.empty?

    notified_user_ids = topic.mentioned_user_ids

    # Send notification for followers
    default_note = {notify_type: "topic", target_type: "Topic", target_id: topic.id, actor_id: topic.user_id, created_at: Time.now, updated_at: Time.now}

    all_records = []
    follower_ids.each do |uid|
      # Without users that has been notified
      next if notified_user_ids.include?(uid)
      # Without topic author
      next if uid == topic.user_id
      all_records << default_note.merge(user_id: uid)
    end

    all_records.each_slice(100) do |records|
      Notification.insert_all(records)
    end
  end
end
