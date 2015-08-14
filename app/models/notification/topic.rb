module Notification
  class Topic < Base
    belongs_to :topic, class_name: 'Topic'

    delegate :body, to: :topic, prefix: true, allow_nil: true

    def notify_hash
      return {} if topic.blank?
      {
        title: '发表了新话题',
        content: topic_body[0, 30],
        content_path: content_path
      }
    end

    def actor
      topic.try(:user)
    end

    def content_path
      return '' if topic.blank?
      url_helpers.topic_path(topic.id)
    end
  end
end
