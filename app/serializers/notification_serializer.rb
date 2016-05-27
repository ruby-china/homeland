class NotificationSerializer < BaseSerializer
  attributes :id, :type, :read, :actor, :mention_type,
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

  belongs_to :actor
  def actor
    object.actor
  end

  def mention_type
    return nil if object.notify_type != 'mention'
    object.target_type
  end

  belongs_to :mention, except: [:abilities, :user]
  def mention
    return nil if object.notify_type != 'mention'
    object.target
  end

  belongs_to :topic, except: [:abilities, :user]
  def topic
    if object.notify_type == 'topic' || object.notify_type == 'node_changed'
      object.try(:target)
    end
  end

  belongs_to :reply, except: [:abilities, :user]
  def reply
    return nil if object.notify_type != 'topic_reply'
    object.try(:target)
  end

  belongs_to :node, only: [:name, :id]
  def node
    return nil if object.notify_type != 'node_changed'
    return nil if object.try(:second_target).blank?
    object.second_target
  end
end
