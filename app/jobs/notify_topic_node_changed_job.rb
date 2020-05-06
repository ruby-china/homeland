# frozen_string_literal: true

class NotifyTopicNodeChangedJob < AsyncJob
  def perform(topic_id, node_id:)
    topic = Topic.find_by_id(topic_id)
    return if topic.blank?
    node = Node.find_by_id(node_id)
    return if node.blank?

    Notification.create! notify_type: "node_changed", user_id: topic.user_id, target: topic, second_target: node
  end
end
