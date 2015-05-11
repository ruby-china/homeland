class NotificationSerializer < BaseSerializer
  attributes :id, :created_at, :updated_at, :read, :mention_type, :mention, :reply
  
  def mention_type
    return nil if not object.is_a?(::Notification::Mention)
    object.mentionable_type
  end
  
  def mention
    return nil if not object.is_a?(::Notification::Mention)
    klass = case object.mentionable_type 
    when "Reply"
      ReplySerializer
    when "Topic"
      TopicSerializer
    else
      return nil
    end
    klass.new(object.mentionable, root: false)
  end
  
  def reply
    return nil if not object.is_a?(::Notification::TopicReply)
    ReplySerializer.new(object.reply, root: false)
  end
end