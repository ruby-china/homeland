class ReplySerializer < BaseSerializer
  attributes :id, :body_html, :created_at, :updated_at, :deleted, :topic_id,
             :user, :likes_count, :abilities

  def user
    UserSerializer.new(object.user, root: false)
  end

  def deleted
    !object.deleted_at.nil?
  end
end
