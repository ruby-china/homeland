module V3
  module Entities
    class Topic < Grape::Entity
      expose :id, :title, :created_at, :updated_at, :replied_at, :replies_count, 
             :node_name, :node_id, :last_reply_user_id, :last_reply_user_login
      expose :user, using: V3::Entities::User
    end
  end
end