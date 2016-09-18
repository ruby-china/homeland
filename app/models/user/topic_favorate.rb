class User
  module TopicFavorate
    extend ActiveSupport::Concern

    # 收藏话题
    def favorite_topic(topic_id)
      return false if topic_id.blank?
      topic_id = topic_id.to_i
      return false if favorited_topic?(topic_id)
      push(favorite_topic_ids: topic_id)
      true
    end

    # 取消对话题的收藏
    def unfavorite_topic(topic_id)
      return false if topic_id.blank?
      topic_id = topic_id.to_i
      pull(favorite_topic_ids: topic_id)
      true
    end

    # 是否收藏过话题
    def favorited_topic?(topic_id)
      favorite_topic_ids.include?(topic_id)
    end

    def favorite_topics_count
      favorite_topic_ids.count
    end
    alias favorites_count favorite_topics_count
  end
end
