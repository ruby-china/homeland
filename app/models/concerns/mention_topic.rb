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
    return if matched_ids.blank?
    matched_ids = matched_ids.map(&:to_i).reject { |id| id == current_topic_id }
    Topic.where("id IN (?)", matched_ids).pluck(:id)
  end

  private
    def create_releated_for_mentioned_topics
      topic_ids = extract_mentioned_topic_ids
      return if topic_ids.blank?
      MentionTopicJob.perform_later(topic_ids, target_type: self.class.name, target_id: self.id, user_id: self.user_id)
    end
end
