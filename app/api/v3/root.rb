require 'doorkeeper/grape/helpers'

module V3
  class Root < Grape::API
    version "v3"
    default_error_formatter :json
    content_type :json, 'application/json'
    format :json

    rescue_from :all do |e|
      case e
      when Mongoid::Errors::DocumentNotFound
        Rack::Response.new(['{ "error" : "Record not found." }'], 404, {}).finish
      else
        # ExceptionNotifier.notify_exception(e) # Uncommit it when ExceptionNotification is available
        if Rails.env.test?
          puts "Error: #{e}\n#{e.backtrace[0,2].join("\n")}"
        else
          Rails.logger.error "Api V3 Error: #{e}\n#{e.backtrace.join("\n")}"
        end
        Rack::Response.new(['{ "error" : "API Error" }'], 500, {}).finish
      end
    end

    helpers Doorkeeper::Grape::Helpers
    helpers V3::Helpers

    mount V3::Topics
    mount V3::Notifications

    get "hello" do
      doorkeeper_authorize!
      { current_user: current_user.login }
    end

    resource :nodes do
      # Get a list of all nodes
      # Example
      #   /Api/nodes.json
      get do
        present Node.all, with: V3::Entities::Node
      end
    end

    # Mark a topic as favorite for current authenticated user
    # Example
    # /Api/user/favorite/qichunren/8.json?token=232332233223:1
    resource :user do
      before do
        doorkeeper_authorize!
      end

      put "favorite/:user/:topic" do
        current_user.favorite_topic(params[:topic])
      end
    end

    resource :users do
      # Get top 20 hot users
      # Example
      # /Api/users.json
      get do
        @users = User.hot.limit(20)
        present @users, with: V3::Entities::DetailUser
      end

      # Get a single user
      # Example
      #   /Api/users/qichunren.json
      get ":user" do
        @user = User.find_login(params[:user])
        present @user, topics_limit: 5, with: V3::Entities::DetailUser
      end

      # List topics for a user
      get ":user/topics" do
        @user = User.find_login(params[:user])
        @topics = @user.topics.recent.limit(page_size)
        present @topics, with: V3::Entities::UserTopic
      end

      # List favorite topics for a user
      get ":user/topics/favorite" do
        @user = User.find_login(params[:user])
        @topics = Topic.find(@user.favorite_topic_ids)
        present @topics, with: V3::Entities::Topic
      end
    end

    # List all cool sites
    # Example
    # GET /Api/sites.json
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
      before do
        doorkeeper_authorize!
      end

      post do
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
