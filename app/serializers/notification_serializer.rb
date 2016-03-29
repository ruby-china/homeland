class NotificationSerializer < BaseSerializer
  attributes :id, :type, :read, :actor,
             :mention_type, :mention, :topic, :reply, :node,
             :created_at, :updated_at

  def serializable_object(options = {})
    cache([object, 'v1.4']) do
      super(options)
    end
  end

  def type
    object.notify_type.classify
  end

  def read
    object.read?
  end

  def actor
    UserSerializer.new(object.actor, root: false) if object.actor
  end

  def mention_type
    return nil if object.notify_type != 'mention'
    object.target_type
  end

  def mention
    return nil if object.notify_type != 'mention'
    klass = case object.target_type
            when 'Reply'
              ReplySerializer
            when 'Topic'
              TopicSerializer
            else
              return nil
    end
    return nil if klass.blank?
    klass.new(object.target, root: false, except: [:abilities, :user])
  end

  def topic
    return nil if object.try(:target).blank?
    if object.notify_type == 'topic' || object.notify_type == 'node_changed'
      TopicSerializer.new(object.target, root: false, except: [:abilities, :user])
    end
  end

  def reply
    return nil if object.notify_type != 'topic_reply'
    ReplyDetailSerializer.new(object.target, root: false, except: [:abilities, :user])
  end

  def node
    return nil if object.notify_type != 'node_changed'
    return nil if object.try(:second_target).blank?
    NodeSerializer.new(object.second_target, root: false, only: [:name, :id])
  end
end
