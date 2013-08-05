require "digest/md5"

module RubyChina
  module APIEntities
    class User < Grape::Entity
      expose :id, :login
      expose(:avatar_url) do |model, opts|
        if model.avatar?
          model.avatar.url(:large)
        else
          hash = Digest::MD5.hexdigest(model.email || "")
          "#{Setting.gravatar_proxy}/avatar/#{hash}.png?s=120"
        end
      end
    end

    class DetailUser < Grape::Entity
      expose :id, :name, :login, :location, :company, :twitter, :website, :bio, :tagline, :github_url
      expose :email do |model, opts|
        model.email_public ? model.email : ''
      end

      # deprecated: gravatar_hash, use avatar_url for user avatar
      expose(:gravatar_hash) { |model, opts| Digest::MD5.hexdigest(model.email || "") }
      expose(:avatar_url) do |model, opts|
        if model.avatar?
          model.avatar.url(:large)
        else
          hash = Digest::MD5.hexdigest(model.email || "")
          "#{Setting.gravatar_proxy}/avatar/#{hash}.png?s=120"
        end
      end
      expose(:topics, :unless => { :collection => true }) do |model, opts|
        model.topics.recent.limit(opts[:topics_limit] ||= 1).as_json(:only => [:id, :title, :created_at, :node_name, :replies_count])
      end
    end

    class UserTopic < Grape::Entity
      expose :id, :title, :body, :body_html, :created_at, :updated_at, :replied_at, :replies_count, :node_name, :node_id, :last_reply_user_login
    end

    class Reply < Grape::Entity
      expose :id, :body, :body_html, :created_at, :updated_at
      expose :user, :using => APIEntities::User
    end
    
    class Topic < Grape::Entity
      expose :id, :title, :created_at, :updated_at, :replied_at, :replies_count, :node_name, :node_id, :last_reply_user_id, :last_reply_user_login
      expose :user, :using => APIEntities::User
    end

    class DetailTopic < Topic
      expose :id, :title, :created_at, :updated_at, :replied_at, :replies_count, :node_name, :node_id, :last_reply_user_id, :last_reply_user_login, :body, :body_html
      expose(:hits) { |topic| topic.hits.to_i }
      expose :user, :using => APIEntities::User
      # replies only exposed when a single topic is fetched
      expose :replies, :using => APIEntities::Reply, :unless => { :collection => true }
    end

    class Node < Grape::Entity
      expose :id, :name, :topics_count, :summary, :section_id, :sort
      expose(:section_name) {|model, opts| model.section.try(:name) }
    end
  end
end
