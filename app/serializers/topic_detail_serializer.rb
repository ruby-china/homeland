# 完整话题详情
# {include:TopicSerializer}
# - *body* [String] 话题正文，原始 Markdown
# - *body_html* [String] 以转换成 HTML 的正文
# - *hits* [Integer] 阅读次数
class TopicDetailSerializer < TopicSerializer
  attributes :body, :body_html, :hits

  def hits
    object.hits.to_i
  end
end
