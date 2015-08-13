class NotificationSerializer < BaseSerializer
  attributes :id, :type, :read, :actor,
             :mention_type, :mention, :reply, :created_at, :updated_at

  def serializable_object(options = {})
    cache([object, 'v1']) do
      super(options)
    end
  end

  def type
    object._type.sub('Notification::', '')
  end

  def actor
    UserSerializer.new(object.actor, root: false) if object.actor
  end

  def mention_type
    return nil unless object.is_a?(::Notification::Mention)
    object.mentionable_type
  end

  def mention
    return nil unless object.is_a?(::Notification::Mention)
    klass = case object.mentionable_type
            when 'Reply'
              ReplySerializer
            when 'Topic'
              TopicSerializer
            else
              return nil
    end
    klass.new(object.mentionable, root: false, except: [:abilities, :user])
  end

  def reply
    return nil unless object.is_a?(::Notification::TopicReply)
    ReplySerializer.new(object.reply, root: false, except: [:abilities, :user])
  end
end
