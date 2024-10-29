class TopicReferenceJob < AsyncJob
  REFERENCE_PATTERN = %r{/topics/(\d+)}

  def perform(item_type, item_id)
    item = item_type.constantize.find_by(id: item_id)
    return if item&.body.blank?

    matched_topic_ids = []
    item.body.gsub(REFERENCE_PATTERN) do
      topic_id = Regexp.last_match(1)
      matched_topic_ids << topic_id if topic_id.present?
    end
    matched_topic_ids.uniq!

    referer_id = item.is_a?(Topic) ? item.id : item.topic_id
    # Avoid reference Topic itself or Reply's Topic
    matched_topic_ids.delete(referer_id.to_s)
    exist_ids = Topic.where(id: matched_topic_ids).pluck(:id)

    Topic.transaction do
      exist_ids.each do |target_id|
        Topic.create_action(:reference, target_type: "Topic", target_id:, user_type: "Topic", user_id: referer_id)
      end

      # Touch targets and referer
      Topic.where(id: [referer_id, exist_ids].flatten).update_all(updated_at: Time.now)
    end
  end
end
