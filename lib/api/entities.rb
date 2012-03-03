require "digest/md5"

module RubyChina
  module APIEntities
    class User < Grape::Entity
      expose :_id, :name, :login, :location, :website, :bio, :tagline, :github_url
      expose(:gravatar_hash) { |model, opts| Digest::MD5.hexdigest(model.email || "") }
    end

    class Topic < Grape::Entity
      expose :_id, :title, :body, :created_at, :updated_at, :replied_at, :replies_count, :node_name
      #FIXME: eager loading doesn't seem to be working here
      expose :user, :using => APIEntities::User
    end
  end
end
