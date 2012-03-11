require "api/entities"
require "api/helpers"

module RubyChina
  class API < Grape::API
    prefix "api"
    error_format :json

    helpers APIHelpers

    # Authentication:
    # APIs marked as 'require authentication' should be provided the user's private token,
    # either in post body or query string, named "token"

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

      # Post a new topic
      # require authentication
      # params:
      #   title
      #   body
      #   node_id
      post do
        authenticate!
        @topic = current_user.topics.new(:title => params[:title], :body => params[:body])
        @topic.node_id = params[:node_id]
        @topic.save!
        #TODO error handling
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
