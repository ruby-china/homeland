# frozen_string_literal: true

class MentionTopicJob < ApplicationJob
  queue_as :notifications

  def perform(topic_ids, target_type:, target_id:, user_id:)
    return if topic_ids.blank?

    topics = Topic.where(id: topic_ids)

    topics.each do |topic|
      next if topic.replies.where(target_type: target_type, target_id: target_id).any?

      reply_param = {
        action: "mention",
        body: "",
        topic: topic,
        target_type: target_type,
        target_id: target_id,
        user_id: user_id
      }

      Reply.create!(reply_param)
    end
  end
end
