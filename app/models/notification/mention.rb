module Notification
  class Mention < Base
    belongs_to :mentionable, polymorphic: true

    delegate :body, to: :mentionable, prefix: true, allow_nil: true

    def notify_hash
      return {} if mentionable.blank?
      {
        title: [mentionable.user_login, '提及你：'].join(' '),
        content: mentionable_body[0, 30],
        content_path: content_path
      }
    end

    def actor
      mentionable.try(:user)
    end

    def content_path
      case mentionable_type.downcase
      when 'topic'
        url_helpers.topic_path(mentionable_id)
      when 'reply'
        return '' if mentionable.blank?
        url_helpers.topic_path(mentionable.topic_id)
      else
        ''
      end
    end
  end
end
