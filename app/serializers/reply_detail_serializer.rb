# 包含原始信息的回帖
#
# == attributes
# {include:ReplySerializer}
# - *topic_title* [String] 话题标题
# - *body* [String] 回帖正文，原始 Markdown
class ReplyDetailSerializer < ReplySerializer
  delegate :title, to: :topic, allow_nil: true

  attributes :body, :topic_title
end
