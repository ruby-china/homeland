require 'sidekiq/web'

Rails.application.routes.draw do
  use_doorkeeper do
    controllers applications: 'oauth/applications',
                authorized_applications: 'oauth/authorized_applications'
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
  resources :teams

  root to: 'home#index'

  devise_for :users, path: 'account', controllers: {
    registrations: :account,
    sessions: :sessions,
    passwords: :passwords,
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  delete 'account/auth/:provider/unbind', to: 'users#auth_unbind', as: 'unbind_account'

  mount RuCaptcha::Engine, at: '/rucaptcha'
  mount Notifications::Engine, at: '/notifications'
  mount StatusPage::Engine, at: '/'

  resources :nodes do
    member do
      post :block
      post :unblock
    end
  end

  get 'topics/node:id', to: 'topics#node', as: 'node_topics'
  get 'topics/node:id/feed', to: 'topics#node_feed', as: 'feed_node_topics', defaults: { format: 'xml' }
  get 'topics/last', to: 'topics#recent', as: 'recent_topics'

  resources :topics do
    member do
      post :reply
      post :favorite
      delete :unfavorite
      post :follow
      delete :unfollow
      post :action
    end
    collection do
      get :no_reply
      get :popular
      get :excellent
      get :favorites
      get :feed, defaults: { format: 'xml' }
      post :preview
    end
    resources :replies
  end

  resources :photos
  resources :likes
  resources :jobs

  get '/search', to: 'search#index', as: 'search'
  get '/search/users', to: 'search#users', as: 'search_users'

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
    resources :users do
      member do
        delete :clean
      end
    end
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

  get 'api', to: 'home#api', as: 'api'
  get 'markdown', to: 'home#markdown', as: 'markdown'

  namespace :api do
    namespace :v3 do
      get 'hello', to: 'root#hello'

      resource :devices
      resource :likes
      resources :nodes
      resources :photos
      resources :notifications do
        collection do
          post :read
          get :unread_count
          delete :all
        end
      end
      resources :topics do
        member do
          post :update
          get :replies
          post :replies
          post :follow
          post :unfollow
          post :favorite
          post :unfavorite
          post :ban
          post :action
        end
      end
      resources :replies do
        member do
          post :update
        end
      end
      resources :users do
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

      match '*path', to: 'root#not_found', via: :all
    end
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: '/sidekiq'
    mount PgHero::Engine, at: "pghero"
  end

  mount JasmineRails::Engine, at: '/specs' if defined?(JasmineRails)

  # WARRING! 请保持 User 的 routes 在所有路由的最后，以便于可以让用户名在根目录下面使用，而又不影响到其他的 routes
  # 比如 http://localhost:3000/huacnlee
  get 'users/city/:id', to: 'users#city', as: 'location_users'
  get 'users', to: 'users#index', as: 'users'

  constraints(id: /#{User::LOGIN_FORMAT}*/) do
    resources :users, path: '', as: 'users' do
      member do
        # User only
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

      resources :team_users, path: 'people' do
        member do
          post :accept
          post :reject
        end
      end
    end
  end

  match '*path', to: 'home#error_404', via: :all
end
