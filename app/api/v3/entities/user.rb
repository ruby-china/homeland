require "digest/md5"

module V3
  module Entities
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
  end
end