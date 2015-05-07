module V3
  module Entities
    class Reply < Grape::Entity
      expose :id, :body, :body_html, :created_at, :updated_at, :deleted_at, :topic_id
      expose :user, using: V3::Entities::User
    end
  end
end