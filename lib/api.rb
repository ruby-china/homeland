require "api/entities"
require "api/helpers"

module RubyChina
  class API < Grape::API
    prefix "api"
    error_format :json

    helpers APIHelpers

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

    resource :nodes do
      # Get a list of all nodes
      get do
        present Node.all, :with => APIEntities::Node
      end
    end
  end
end
