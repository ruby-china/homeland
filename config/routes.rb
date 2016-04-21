Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  use_doorkeeper do
    controllers applications: 'oauth/applications', authorized_applications: 'oauth/authorized_applications'
  end

  resources :sites
  resources :pages, path: 'wiki' do
    collection do
      get :recent
      post :preview
    end
    member do
      get :comments
    end
  end
  resources :comments
  resources :notes do
    collection do
      post :preview
    end
  end
  resources :devices

  root to: 'home#index'

  devise_for :users, path: 'account', controllers: {
    registrations: :account,
    sessions: :sessions,
    passwords: :passwords,
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  delete 'account/auth/:provider/unbind' => 'users#auth_unbind', as: 'unbind_account'
  post 'account/update_private_token' => 'users#update_private_token', as: 'update_private_token_account'

  mount RuCaptcha::Engine => "/rucaptcha"
  mount Notifications::Engine => '/notifications'
  mount StatusPage::Engine, at: '/'

  resources :nodes do
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
      post :reply
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

  resources :photos
  resources :likes
  resources :jobs

  get '/search' => 'search#index', as: 'search'

  namespace :admin do
    root to: 'home#index', as: 'root'
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
      resources :versions, controller: :page_versions do
        member do
          post :revert
        end
      end
    end
    resources :comments
    resources :site_nodes
    resources :sites do
      member do
        post :undestroy
      end
    end
    resources :locations
    resources :exception_logs do
      collection do
        post :clean
      end
    end
    resources :applications
  end

  get 'api' => 'home#api', as: 'api'
  get 'twitter' => 'home#twitter', as: 'twitter'
  get 'markdown' => 'home#markdown', as: 'markdown'

  # mount API::Dispatch => '/api'
  namespace :api do
    namespace :v3 do
      resource :devices
      resource :likes
      resources :notifications do
        collection do
          post :read
          get :unread_count
          delete :all
        end
      end
      resources :replies do
        member do
          post :update
        end
      end
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

  resources :users, path: '', as: 'users' do
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
