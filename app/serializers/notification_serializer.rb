# 通知
#
# == attributes
# - *id* [Integer] 编号
# - *type* [String] 通知类型
# - *read* [Boolean] 是否已读
# - *actor* {UserSerializer} 动作发起者
# - *mention_type* [String] 提及的数据类型 Topic, Reply
# - *created_at* [DateTime] 创建时间
# - *updated_at* [DateTime] 更新时间
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
  # 通知对应的提及的数据
  # @return {TopicSerializer, ReplySerializer}
  def mention
    return nil if object.notify_type != 'mention'
    object.target
  end

  belongs_to :topic, except: [:abilities, :user]

  # 通知对应的话题
  # @return {TopicSerializer}
  def topic
    if object.notify_type == 'topic' || object.notify_type == 'node_changed'
      object.try(:target)
    elsif object.notify_type == 'topic_reply'
      object.try(:second_target)
    elsif object.notify_type == 'mention'
      if object.target_type == 'Topic'
        object.try(:target)
      elsif object.target_type == 'Reply'
        object.try(:second_target)
      end
    end
  end

  belongs_to :reply, except: [:abilities, :user]
  # 通知对应的回帖
  # @return {ReplySerializer}
  def reply
    return nil if object.notify_type != 'topic_reply'
    object.try(:target)
  end

  belongs_to :node, only: [:name, :id]
  # 通知对应的节点
  # @return {NodeSerializer}
  def node
    return nil if object.notify_type != 'node_changed'
    return nil if object.try(:second_target).blank?
    object.second_target
  end
end
