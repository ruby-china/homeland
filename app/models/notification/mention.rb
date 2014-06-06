# coding: utf-8
class Notification::Mention < Notification::Base
  belongs_to :mentionable, polymorphic: true

  delegate :body, to: :mentionable, prefix: true, allow_nil: true

  def notify_hash
    return if self.mentionable.blank?
    {
      title: [self.mentionable.user_login, '提及你：'].join(' '),
      content: self.mentionable_body[0, 30],
      content_path: self.content_path
    }
  end

  def content_path
    case self.mentionable_type.downcase
    when 'topic'
      url_helpers.topic_path(self.mentionable_id)
    when 'reply'
      return '' if self.mentionable.blank?
      url_helpers.topic_path(self.mentionable.topic_id)
    else
      ''
    end
  end
end
