# coding: utf-8
class Notification::Topic < Notification::Base
  belongs_to :topic, class_name: "Topic"

  delegate :body, to: :topic, prefix: true, allow_nil: true

  def notify_hash
    return {} if self.topic.blank?
    {
      title: '关注的话题有了新回复:',
      content: self.topic_body[0, 30],
      content_path: self.content_path
    }
  end
  
  def actor
    self.topic.try(:user)
  end

  def content_path
    return '' if self.topic.blank?
    url_helpers.topic_path(self.topic.id)
  end
end
