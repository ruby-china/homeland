module V3
  module Entities
    class DetailUser < Grape::Entity
      expose :id, :name, :login, :location, :company, :twitter, :website, :bio, :tagline, :github
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
    end

  end
end