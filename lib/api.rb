require "api/entities"
Dir[Rails.root.join("lib/api/helpers/*.rb")].each {|f| require f}

module RubyChina
  class API < Grape::API
    prefix "api"
    error_format :json

    helpers APIHelper::Topic
    helpers APIHelper::User

    resource :topics do
      # Get active topics list
      # params[:size] could be specified to limit the results
      # params[:size]: default is 15, max is 100
      get do
        @topics = Topic.last_actived
          .limit(page_size)
          .includes(:user)
        present @topics, :with => APIEntities::Topic
      end
    end
  end
end
