module RubyChina
  module APIEntities
    class User < Grape::Entity
      expose :_id, :name, :login, :location, :website, :github
    end

    class Topic < Grape::Entity
      expose :_id, :body, :created_at, :updated_at
      expose :user, :using => APIEntities::User
    end
  end
end
