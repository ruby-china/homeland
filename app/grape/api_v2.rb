require "entities"
require "helpers"

module RubyChina
  class APIV2 < Grape::API
    prefix "api"
    version "v2"
    error_format :json

    rescue_from :all do |e|
      case e
      when Mongoid::Errors::DocumentNotFound
        Rack::Response.new(['not found'], 404, {}).finish
      else
        # ExceptionNotifier.notify_exception(e) # Uncommit it when ExceptionNotification is available
        Rails.logger.error "APIv2 Error: #{e}\n#{e.backtrace.join("\n")}"
        Rack::Response.new(['error'], 500, {}).finish
      end
    end

    helpers APIHelpers

    # Authentication:
    # APIs marked as 'require authentication' should be provided the user's private token,
    # either in post body or query string, named "token"

    resource :topics do

      # Get active topics list
      # params[:page]
      # params[:per_page]: default is 30
      # params[:type]: default(or empty) excellent no_reply popular last
      # Example
      #   /api/topics/index.json?page=1&per_page=15
      get do
        @topics = Topic.last_actived.without_hide_nodes
        @topics = @topics.send(params[:type]) if ['excellent', 'no_reply', 'popular', 'recent'].include?(params[:type])
        @topics = @topics.includes(:user).paginate(page: params[:page], per_page: params[:per_page] || 30)
        present @topics, with: APIEntities::Topic
      end

      # Get active topics of the specified node
      # params[:id]: node id
      # params[:page]
      # params[:size] or params[:per_page]: default is 15, maximum is 100
      # params[:type]: default(or empty) excellent no_reply popular last
      # other params are same to those of topics#index
      # Example
      #   /api/topics/node/1.json?size=30
      get "node/:id" do
        @node = Node.find(params[:id])
        @topics = @node.topics.last_actived
        @topics = @topics.send(params[:type]) if ['excellent', 'no_reply', 'popular', 'recent'].include?(params[:type])
        @topics = @topics.includes(:user).paginate(page: params[:page], per_page: params[:per_page] || page_size)
        present @topics, with: APIEntities::Topic
      end

      # Post a new topic
      # require authentication
      # params:
      #   title
      #   body
      #   node_id
      post do
        authenticate!
        @topic = current_user.topics.new(title: params[:title], body: params[:body])
        @topic.node_id = params[:node_id]
        if @topic.save
          present @topic, with: APIEntities::DetailTopic
        else
          error!({ error: @topic.errors.full_messages }, 400)
        end
      end

      # Get topic detail
      # params:
      #   include_deleted(optional)
      # Example
      #   /api/topics/1.json
      get ":id" do
        @topic = Topic.find(params[:id])
        @topic.hits.incr(1)
        present @topic, with: APIEntities::DetailTopic, include_deleted: params[:include_deleted]
      end

      # Post a new reply
      # require authentication
      # params:
      #   body
      # Example
      #   /api/topics/1/replies.json
      post ":id/replies" do
        authenticate!
        @topic = Topic.find(params[:id])
        @reply = @topic.replies.build(body: params[:body])
        @reply.user_id = current_user.id
        if @reply.save
          present @reply, with: APIEntities::Reply
        else
          error!({"error" => @reply.errors.full_messages }, 400)
        end
      end

      # Follow a topic
      # require authentication
      # params:
      #   NO
      # Example
      #   /api/topics/1/follow.json
      post ":id/follow" do
        authenticate!
        @topic = Topic.find(params[:id])
        @topic.push_follower(current_user.id)
      end

      # Unfollow a topic
      # require authentication
      # params:
      #   NO
      # Example
      #   /api/topics/1/unfollow.json
      post ":id/unfollow" do
        authenticate!
        @topic = Topic.find(params[:id])
        @topic.pull_follower(current_user.id)
      end

      # Add/Remove a topic to/from favorite
      # require authentication
      # params:
      #   type(optional) default is empty, set it unfavoritate to remove favorite
      # Example
      #   /api/topics/1/favorite.json
      post ":id/favorite" do
        authenticate!
        if params[:type] == "unfavorite"
          current_user.unfavorite_topic(params[:id])
        else
          current_user.favorite_topic(params[:id])
        end
      end
    end

    resource :nodes do
      # Get a list of all nodes
      # Example
      #   /api/nodes.json
      get do
        present Node.all, with: APIEntities::Node
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
        present @users, with: APIEntities::DetailUser
      end

      # Get a single user
      # Example
      #   /api/users/qichunren.json
      get ":user" do
        @user = User.where(login: /^#{params[:user]}$/i).first
        present @user, topics_limit: 5, with: APIEntities::DetailUser
      end

      # List topics for a user
      get ":user/topics" do
        @user = User.where(login: /^#{params[:user]}$/i).first
        @topics = @user.topics.recent.limit(page_size)
        present @topics, with: APIEntities::UserTopic
      end

      # List favorite topics for a user
      get ":user/topics/favorite" do
        @user = User.where(login: /^#{params[:user]}$/i).first
        @topics = Topic.find(@user.favorite_topic_ids)
        present @topics, with: APIEntities::Topic
      end
    end

    resources :notifications do
      # Get notifications of current user, this API won't mark notifications as read
      # require authentication
      # params[:page]
      # params[:per_page]: default is 20
      # Example
      #   /api/notifications.json?page=1&per_page=20
      get do
        authenticate!
        @notifications = current_user.notifications.recent.paginate page: params[:page], per_page: params[:per_page] || 20
        present @notifications, with: APIEntities::Notification
      end

      # Delete all notifications of current user
      # require authentication
      # params:
      #   NO
      # Example
      #   DELETE /api/notifications.json
      delete do
        authenticate!
        current_user.notifications.delete_all
        true
      end

      # Delete all notifications of current user
      # require authentication
      # params:
      #   id
      # Example
      #   DELETE /api/notifications/1.json
      delete ":id" do
        authenticate!
        @notification = current_user.notifications.find params[:id]
        @notification.destroy
        true
      end
    end

    # List all cool sites
    # Example
    # GET /api/sites.json
    resource :sites do
      get do
        @site_nodes = SiteNode.all.includes(:sites).desc('sort')
        @site_nodes.as_json(except: :sort, include: {
          sites: {
            only: [:name, :url, :desc, :favicon, :created_at]
          }
        })
      end
    end

    resource :photos do
      post do
        authenticate!
        @photo = Photo.new
        puts "------ #{params.inspect}"
        @photo.image = params[:Filedata]
        @photo.user_id = current_user.id
        if @photo.save
          puts "------ #{@photo.inspect}"
          @photo.image.url
        else
          error!({"error" => @photo.errors.full_messages }, 400)
        end
      end
    end
  end
end
