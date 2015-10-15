class TopicSerializer < BaseSerializer
  attributes :id, :title, :created_at, :updated_at, :replied_at, :replies_count,
             :node_name, :node_id, :last_reply_user_id, :last_reply_user_login,
             :user, :deleted, :excellent, :abilities

  def user
    UserSerializer.new(object.user, root: false)
  end

  def deleted
    !object.deleted_at.nil?
  end

  def excellent
    object.excellent == 1
  end
end
