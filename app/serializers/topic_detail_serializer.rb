class TopicDetailSerializer < TopicSerializer
  attributes :body, :body_html, :hits
  
  def hits
    object.hits.to_i
  end
end