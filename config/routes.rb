Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  use_doorkeeper do
    controllers applications: 'oauth/applications', authorized_applications: 'oauth/authorized_applications'
  end

  resources :sites, only: [:index, :new, :create]
  resources :pages, path: 'wiki', except: [:destroy] do
    collection do
      get :recent
      post :preview
    end
    member do
      get :comments
    end
  end
  resources :comments, only: [:create]
  resources :notes do
    collection do
      post :preview
    end
  end
  resources :devices, only: [:destroy]

  root to: 'home#index'

  devise_for :users, path: 'account', controllers: {
    registrations: :account,
    sessions: :sessions,
    passwords: :passwords,
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  delete 'account/auth/:provider/unbind' => 'users#auth_unbind', as: 'unbind_account'
  post 'account/update_private_token' => 'users#update_private_token', as: 'update_private_token_account'

  mount RuCaptcha::Engine => '/rucaptcha'
  mount Notifications::Engine => '/notifications'
  mount StatusPage::Engine, at: '/'

  resources :nodes, only: [:index] do
    member do
      post :block
      post :unblock
    end
  end

  get 'topics/node:id' => 'topics#node', as: 'node_topics'
  get 'topics/node:id/feed' => 'topics#node_feed', as: 'feed_node_topics', defaults: { format: 'xml' }
  get 'topics/last' => 'topics#recent', as: 'recent_topics'

  resources :topics do
    member do
      post :favorite
      delete :unfavorite
      post :follow
      delete :unfollow
      patch :suggest
      delete :unsuggest
      post :ban
    end
    collection do
      get :no_reply
      get :popular
      get :excellent
      get :feed, defaults: { format: 'xml' }
      post :preview
    end
    resources :replies
  end

  resources :photos, only: [:create]
  resources :likes, only: [:create, :destroy]
  resources :jobs, only: [:index]

  get '/search' => 'search#index', as: 'search'

  namespace :admin do
    root to: 'home#index', as: 'root'
    resources :site_configs, only: [:index, :edit, :update]
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
      resources :versions, controller: :page_versions, only: [:index, :show] do
        member do
          post :revert
        end
      end
    end
    resources :comments, except: [:create, :new, :show]
    resources :site_nodes
    resources :sites do
      member do
        post :undestroy
      end
    end
    resources :locations
    resources :exception_logs, only: [:index, :show, :destroy] do
      collection do
        post :clean
      end
    end
    resources :applications
  end

  get 'api' => 'home#api', as: 'api'
  get 'twitter' => 'home#twitter', as: 'twitter'
  get 'markdown' => 'home#markdown', as: 'markdown'

  namespace :api do
    namespace :v3 do
      match 'hello', via: :get, to: 'root#hello'

      resource :devices, only: [:create, :destroy]
      resource :likes, only: [:create, :destroy]
      resources :nodes, only: [:index, :show]
      resources :photos, only: [:create]
      resources :notifications, only: [:index, :destroy] do
        collection do
          post :read
          get :unread_count
          delete :all
        end
      end
      resources :topics, except: [:new] do
        member do
          post :update
          get :replies
          post :replies
          post :follow
          post :unfollow
          post :favorite
          post :unfavorite
          post :ban
        end
      end
      resources :replies, only: [:show, :destroy] do
        member do
          post :update
        end
      end
      resources :users, only: [:index, :show] do
        collection do
          get :me
        end
        member do
          get :topics
          get :replies
          get :favorites
          get :followers
          get :following
          get :blocked
          post :follow
          post :unfollow
          post :block
          post :unblock
        end
      end

      match '*path', via: :all, to: 'root#not_found'
    end
  end

  require 'sidekiq/web'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  # WARRING! 请保持 User 的 routes 在所有路由的最后，以便于可以让用户名在根目录下面使用，而又不影响到其他的 routes
  # 比如 http://ruby-china.org/huacnlee
  get 'users/city/:id' => 'users#city', as: 'location_users'
  get 'users' => 'users#index', as: 'users'

  resources :users, path: '', as: 'users', only: [:index, :show] do
    member do
      get :topics
      get :replies
      get :favorites
      get :notes
      get :blocked
      post :block
      post :unblock
      post :follow
      post :unfollow
      get :followers
      get :following
      get :calendar
    end
  end

  match '*path', via: :all, to: 'home#error_404'
end
