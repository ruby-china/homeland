module V3
  module Entities
    class DetailTopic < Grape::Entity
      expose :id, :title, :created_at, :updated_at, :replied_at, 
             :replies_count, :node_name, :node_id, :last_reply_user_id, 
             :last_reply_user_login, :body, :body_html
      expose(:hits) { |topic| topic.hits.to_i }
      expose :user, using: V3::Entities::User
      
      # replies only exposed when a single topic is fetched
      expose(:replies, unless: { collection: true }) do |model, opts|
        replies = model.replies
        replies = replies.unscoped if opts[:include_deleted]
        V3::Entities::Reply.represent(replies.asc(:_id))
      end
    end
  end
end