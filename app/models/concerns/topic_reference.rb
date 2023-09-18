module TopicReference
  extend ActiveSupport::Concern

  REFERENCE_PATTERN = %r{/topics/(\d+)}

  included do
    before_save :extract_references
  end

  def extract_references
    body = self.body
    return if body.blank?

    matched_topic_ids = []
    body.gsub(REFERENCE_PATTERN) do
      topic_id = Regexp.last_match(1)
      matched_topic_ids << topic_id if topic_id.present?
    end
    matched_topic_ids.uniq!

    item_id = is_a?(Topic) ? id : topic_id
    # Avoid reference Topic itself or Reply's Topic
    matched_topic_ids.delete(item_id.to_s)

    exist_ids = Topic.where(id: matched_topic_ids).pluck(:id)
    Topic.transaction do
      exist_ids.each do |target_id|
        Topic.create_action(:reference, target_type: "Topic", target_id: target_id, user_type: "Topic", user_id: item_id)
      end
    end
  end
end