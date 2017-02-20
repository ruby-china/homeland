# 话题信息
# @class ReplySerializer
#
# == attributes
# - *id* [Integer] 编号
# - *topic_id* [Integer] 话题编号
# - *deleted* [Boolean] 是否已删除
# - *likes_count* [Integer] 赞数量
# - *user* {UserSerializer} 最后回复者用户对象
# - *created_at* [DateTime] 创建时间
# - *updated_at* [DateTime] 更新时间

# 包含原始信息的回帖
# @class ReplyDetailSerializer
#
# == attributes
# {include:ReplySerializer}
# - *topic_title* [String] 话题标题
# - *body* [String] 回帖正文，原始 Markdown
if reply
  json.cache! ['v1.2', reply, defined?(detail)] do
    json.(reply, :id, :body_html, :topic_id, :created_at, :updated_at,
          :likes_count, :action, :target_type)
    json.deleted reply.deleted_at.present?
    json.user do
      json.partial! 'user', user: reply.user
    end

    if defined?(detail)
      json.(reply, :body)
      json.topic_title reply.topic.try(:title)
    end
  end

  # Mention Target
  if reply.action == 'mention'
    json.mention_topic do
      if reply.target_type == 'Topic'
        json.partial! 'topic', topic: reply.target
      else
        json.partial! 'topic', topic: reply&.target&.topic
      end
    end
  end

  json.partial! 'abilities', object: reply
end
