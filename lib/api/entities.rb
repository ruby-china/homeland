require "digest/md5"

module RubyChina
  module APIEntities
    class User < Grape::Entity
      expose :_id, :name, :login, :location, :website, :bio, :tagline, :github_url
      expose(:gravatar_hash) { |model, opts| Digest::MD5.hexdigest(model.email || "") }
      expose(:avatar_url) { |model, opts| model.avatar? ? model.avatar.url(:normal) : "" }
    end

    class Topic < Grape::Entity
      expose :_id, :title, :body, :body_html, :created_at, :updated_at, :replied_at, :replies_count, :node_name, :node_id, :last_reply_user_login
      expose :user, :using => APIEntities::User
    end
  end
end
