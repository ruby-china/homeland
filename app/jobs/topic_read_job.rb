# frozen_string_literal: true

class TopicReadJob < AsyncJob
  def perform(topic_id:, user_id:, replies_ids: nil)
    topic = Topic.find_by_id(topic_id)
    return if topic.blank?
    user = User.find_by_id(user_id)
    return if user.blank?

    return if user.topic_read?(topic)
    replies_ids ||= topic.replies.pluck(:id)

    any_sql = "(target_type = 'Topic' AND target_id = ?) OR (target_type = 'Reply' AND target_id in (?))"

    user.notifications.unread
      .where(any_sql, topic.id, replies_ids)
      .update_all(read_at: Time.now)
    Notification.realtime_push_to_client(user)
    # For last_reply_id is nil
    last_reply_id = topic.last_reply_id || -1
    Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", last_reply_id)
  end
end
