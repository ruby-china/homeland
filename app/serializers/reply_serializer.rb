class ReplySerializer < BaseSerializer
  attributes :id, :body, :body_html, :created_at, :updated_at, :deleted, :topic_id
  
  has_one :user
  
  def deleted
    object.deleted_at != nil
  end
end