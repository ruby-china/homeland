# coding: utf-8
class Notification::NodeChanged < Notification::Base
  belongs_to :topic
  belongs_to :node
  
  delegate :name, to: :node, allow_nil: true, prefix: true

  def notify_hash
    return {} if self.topic.blank?
    {
      title: "你发布的话题被管理员移动到了 #{self.node_name} 节点。",
      content: '',
      content_path: self.content_path
    }
  end

  def content_path
    return '' if self.topic.blank?
    url_helpers.topic_path(self.topic_id)
  end
end
