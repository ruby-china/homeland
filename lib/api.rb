require "api/entities"
Dir[Rails.root.join("lib/api/helpers/*.rb")].each {|f| require f}

module RubyChina
  class API < Grape::API
    prefix "api"
    error_format :json

    helpers APIHelper::Topic

    resource :topics do
      get do
        @topics = Topic.last_actived.limit(15).includes(:user)
        present @topics, :with => APIEntities::Topic
      end
    end
  end
end
