# frozen_string_literal: true

class User
  # 对话题、回帖点赞
  module Likeable
    extend ActiveSupport::Concern

    included do
      # Action for Topic
      action_store :like, :topic, counter_cache: true
      # Action for Reply
      action_store :like, :reply, counter_cache: true
    end

    def like(likeable)
      return false if likeable.blank?
      return false if likeable.user_id == id
      create_action(:like, target: likeable)
    end

    def unlike(likeable)
      return false if likeable.blank?
      destroy_action(:like, target: likeable)
    end

    def liked?(likeable)
      find_action(:like, target: likeable).present?
    end

    # Get user liked replies by a reply list
    def like_reply_ids_by_replies(replies)
      return [] if replies.blank?
      return [] if like_reply_ids.blank?
      # Intersection between reply ids and user like_reply_ids
      like_reply_actions.where(target_id: replies.collect(&:id)).pluck(:target_id)
    end
  end
end
