class ReplyDetailSerializer < ReplySerializer
  delegate :title, to: :topic, allow_nil: true

  attributes :body, :topic_title
end
