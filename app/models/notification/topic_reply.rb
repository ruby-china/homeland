module Notification
  class TopicReply < Base
    belongs_to :reply, class_name: 'Reply'

    delegate :body, to: :reply, prefix: true, allow_nil: true

    def notify_hash
      return {} if reply.blank?
      {
        title: '关注的话题有了新回复:',
        content: reply_body[0, 30],
        content_path: content_path
      }
    end

    def actor
      reply.try(:user)
    end

    def content_path
      return '' if reply.blank?
      url_helpers.topic_path(reply.topic_id)
    end
  end
end
