# frozen_string_literal: true

class User
  # 用户对话题的动作
  module TopicActions
    extend ActiveSupport::Concern

    included do
      action_store :favorite, :topic
    end

    def favorites_count
      favorite_topic_actions.count
    end

    # 是否读过 topic 的最近更新
    def topic_read?(topic)
      # 用 last_reply_id 作为 cache key ，以便不热门的数据自动被 Memcached 挤掉
      last_reply_id = topic.last_reply_id || -1
      Rails.cache.read("user:#{id}:topic_read:#{topic.id}") == last_reply_id
    end

    def filter_readed_topics(topics)
      t1 = Time.now
      return [] if topics.blank?
      cache_keys = topics.map { |t| "user:#{id}:topic_read:#{t.id}" }
      results = Rails.cache.read_multi(*cache_keys)
      ids = []
      topics.each do |topic|
        val = results["user:#{id}:topic_read:#{topic.id}"]
        if val == (topic.last_reply_id || -1)
          ids << topic.id
        end
      end
      t2 = Time.now
      logger.info "User filter_readed_topics (#{(t2 - t1) * 1000}ms)"
      ids
    end

    # 将 topic 的最后回复设置为已读
    def read_topic(topic, opts = {})
      return if topic.blank?
      return if self.topic_read?(topic)

      opts[:replies_ids] ||= topic.replies.pluck(:id)

      any_sql = "
        (target_type = 'Topic' AND target_id = ?) or
        (target_type = 'Reply' AND target_id in (?))
      "
      notifications.unread
                   .where(any_sql, topic.id, opts[:replies_ids])
                   .update_all(read_at: Time.now)
      Notification.realtime_push_to_client(self)

      # 处理 last_reply_id 是空的情况
      last_reply_id = topic.last_reply_id || -1
      Rails.cache.write("user:#{id}:topic_read:#{topic.id}", last_reply_id)
    end
  end
end
