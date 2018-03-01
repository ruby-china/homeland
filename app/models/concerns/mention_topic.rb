# frozen_string_literal: true

module MentionTopic
  extend ActiveSupport::Concern

  TOPIC_LINK_REGEXP = %r{://#{Setting.domain}/topics/([\d]+)}i

  included do
    attr_accessor :mentioned_topic_ids

    after_save :create_releated_for_mentioned_topics
  end

  def extract_mentioned_topic_ids
    matched_ids = body.scan(TOPIC_LINK_REGEXP).flatten
    current_topic_id = self.class.name == "Topic" ? self.id : self.topic_id
    if matched_ids.any?
      matched_ids = matched_ids.map(&:to_i).reject { |id| id == current_topic_id }
      self.mentioned_topic_ids = Topic.where("id IN (?)", matched_ids).pluck(:id)
    end
  end

  private
    def create_releated_for_mentioned_topics
      extract_mentioned_topic_ids
      return false if self.mentioned_topic_ids.blank?
      Reply.transaction do
        self.mentioned_topic_ids.each do |topic_id|
          topic = Topic.find_by(id: topic_id)
          next if topic.blank?
          next if topic.replies.where(target: self).any?
          Reply.create_system_event!(user: self.user, topic: topic, action: "mention", target: self)
        end
      end
    end
end
