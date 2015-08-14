module Notification
  class NodeChanged < Base
    belongs_to :topic
    belongs_to :node

    delegate :name, to: :node, allow_nil: true, prefix: true

    def notify_hash
      return {} if topic.blank?
      {
        title: "你发布的话题被管理员移动到了 #{node_name} 节点。",
        content: '',
        content_path: content_path
      }
    end

    def content_path
      return '' if topic.blank?
      url_helpers.topic_path(topic_id)
    end
  end
end
