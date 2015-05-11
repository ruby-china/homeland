class TopicSerializer < BaseSerializer
  attributes :id, :title, :created_at, :updated_at, :replied_at, :replies_count,
             :node_name, :node_id, :last_reply_user_id, :last_reply_user_login, :deleted

  has_one :user
  
  def deleted
    object.deleted_at != nil
  end
end