# 完整话题详情
class TopicDetailSerializer < TopicSerializer
  attributes :body, :body_html, :hits, :likes_count, :suggested_at

  def hits
    object.hits.to_i
  end
end
