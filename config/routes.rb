RubyChina::Application.routes.draw do

  resources :posts
  resources :pages, :path => "wiki" do
    collection do
      get :recent
    end
  end
  resources :comments
  resources :notes
  match "/uploads/*path" => "gridfs#serve"
  root :to => "home#index"  
  match "auth/:provider/callback", :to => "home#auth_callback"  
  match "auth/:provider/unbind", :to => "home#auth_unbind"  
  
  devise_for :users, :path => "account"
  resources :users, :only => :show
  resources :notifications, :only => [:index, :destroy] do
    collection do
      put :mark_all_as_read
    end
  end
  
  resources :nodes
  
  match "topics/node:id" => "topics#node", :as => :node_topics
  match "topics/last" => "topics#recent", :as => :recent_topics
  resources :topics do
    member do
      post :reply
    end
    collection do
      get :search
      get :feed
    end
  end
  resources :replies
  resources :photos do
    collection do
      get :tiny_new
    end
  end

  namespace :cpanel do 
    root :to => "home#index"
    resources :site_configs
    resources :replies
    resources :topics
    resources :nodes
    resources :sections
    resources :users
    resources :photos
    resources :posts
    resources :pages
  end  
  
  mount Resque::Server.new, :at => "/resque"
  if Rails.env.development?
    mount TopicMailer::Preview => 'mails/topic'
    mount UserMailer::Preview => 'mails/user'
  end
end
