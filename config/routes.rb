RubyChina::Application.routes.draw do
  require 'api'

  resources :sites
  resources :pages, :path => "wiki" do
    collection do
      get :recent
      post :preview
    end
  end
  resources :comments
  resources :notes
  root :to => "home#index"

  devise_for :users, :path => "account", :controllers => {
      :registrations => :account,
      :sessions => :sessions,
      :omniauth_callbacks => "users/omniauth_callbacks"
    }
  devise_scope :users do
    get "account/update_private_token" => "account#update_private_token", :as => :update_private_token_account
  end

  match "account/auth/:provider/unbind", :to => "users#auth_unbind"

  resources :notifications, :only => [:index, :destroy] do
    collection do
      post :clear
    end
  end

  resources :nodes

  match "topics/node:id" => "topics#node", :as => :node_topics
  match "topics/node:id/feed" => "topics#node_feed", :as => :feed_node_topics
  match "topics/last" => "topics#recent", :as => :recent_topics
  resources :topics do
    member do
      post :reply
      post :favorite
      post :follow
      post :unfollow
    end
    collection do
      get :no_reply
      get :feed
      post :preview
    end
    resources :replies
  end

  resources :photos
  resources :likes

  match "/search" => "search#index", :as => :search
  match "/search/wiki" => "search#wiki", :as => :search_wiki

  namespace :cpanel do
    root :to => "home#index"
    resources :site_configs
    resources :replies
    resources :topics do
      member do
        post :suggest
        post :unsuggest
        post :undestroy
      end
    end
    resources :nodes
    resources :sections
    resources :users
    resources :photos
    resources :pages do
      resources :versions, :controller => :page_versions do
        member do
          post :revert
        end
      end
    end
    resources :comments
    resources :site_nodes
    resources :sites
    resources :locations
  end

  match "api", :to => "home#api"
  mount RubyChina::API => "/"

  # WARRING! 请保持 User 的 routes 在所有路由的最后，以便于可以让用户名在根目录下面使用，而又不影响到其他的 routes
  # 比如 http://ruby-china.org/huacnlee
  match "users/city/:id", :to => "users#city", :as => :location_users
  match "users", :to => "users#index", :as => :users
  resources :users, :path => "" do
    member do
      get :topics
      get :favorites
    end
  end

end
