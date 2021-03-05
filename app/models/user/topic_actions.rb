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

    # Determine user was read topic latest updates
    def topic_read?(topic)
      # Use last_reply_id as cache key, for implement cache by LRU, so the popular cache will keep
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
      logger.debug "  User filter_readed_topics (#{(t2 - t1) * 1000}ms)"
      ids
    end

    # Mark latest topic update as read
    def read_topic(topic)
      TopicReadJob.perform_later(topic_id: topic.id, user_id: id)
    end
  end
end
