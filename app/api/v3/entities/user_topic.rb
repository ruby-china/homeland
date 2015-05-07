module V3
  module Entities
    class UserTopic < Grape::Entity
      expose :id, :title, :body, :body_html, :created_at, :updated_at, :replied_at, :replies_count, :node_name, :node_id, :last_reply_user_login
    end
  end
end