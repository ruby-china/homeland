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
      # params[:page]
      # params[:per_page]: default is 30
      # Example
      #   /api/topics/index.json?page=1&per_page=15
      get do
        @topics = Topic.last_actived.includes(:user).paginate(:page => params[:page], :per_page => params[:per_page]||30)
        present @topics, :with => APIEntities::Topic
      end

      # Get active topics of the specified node
      # params[:id]: node id
      # other params are same to those of topics#index
      # Example
      #   /api/topics/node/1.json?size=30
      get "node/:id" do
        @node = Node.find(params[:id])
        @topics = @node.topics.last_actived
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

      # Get topic detail
      # Example
      #   /api/topics/1.json
      get ":id" do
        @topic = Topic.includes(:replies => [:user]).where(:_id => params[:id]).first
        present @topic, :with => APIEntities::Topic
      end
    end

    resource :nodes do
      # Get a list of all nodes
      # Example
      #   /api/nodes.json
      get do
        present Node.all, :with => APIEntities::Node
      end
    end

    # Mark a topic as favorite for current authenticated user
    # Example
    # /api/user/favorite/qichunren/8.json?token=232332233223:1
    resource :user do
      put "favorite/:user/:topic" do
        authenticate!
        current_user.favorite_topic(params[:topic])
      end
    end

    resource :users do
      # Get top 20 hot users
      # Example
      # /api/users.json
      get do
        @users = User.hot.limit(20)
        present @users, :with => APIEntities::DetailUser
      end

      # Get a single user
      # Example
      #   /api/users/qichunren.json
      get ":user" do
        @user = User.where(:login => /^#{params[:user]}$/i).first
        present @user, :topics_limit => 5, :with => APIEntities::DetailUser
      end


      # List topics for a user
      get ":user/topics" do
        @user = User.where(:login => /^#{params[:user]}$/i).first
        @topics = @user.topics.recent.limit(page_size)
        present @topics, :with => APIEntities::UserTopic
      end

      # List favorite topics for a user
      get ":user/topics/favorite" do
        @user = User.where(:login => /^#{params[:user]}$/i).first
        @topics = Topic.find(@user.favorite_topic_ids)
        present @topics, :with => APIEntities::Topic
      end
    end

    # List all cool sites
    # Example
    # GET /api/sites.json
    resource :sites do
      get do
        @site_nodes = SiteNode.all.includes(:sites).desc('sort')
        @site_nodes.as_json(:except => :sort, :include => {
          :sites => {
            :only => [:name, :url, :desc, :favicon, :created_at]
          }
        })
      end
    end

  end
end
