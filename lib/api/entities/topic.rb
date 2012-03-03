module RubyChina
  module APIEntities
    class Topic < Grape::Entity
      expose :_id, :body, :created_at, :updated_at
      expose :user
    end
  end
end
