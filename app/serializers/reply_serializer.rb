class ReplySerializer < BaseSerializer
  attributes :id, :body, :body_html, :created_at, :updated_at, :deleted, :topic_id,
             :user

  def user
    UserSerializer.new(object.user, root: false)
  end

  def deleted
    object.deleted_at != nil
  end
end