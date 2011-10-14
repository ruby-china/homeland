Homeland::Application.routes.draw do
  

  resources :notes
  match "/file/*path" => "gridfs#serve"
  root :to => "topics#index"  
  match "auth/:provider/callback", :to => "home#auth_callback"  
  match "auth/:provider/unbind", :to => "home#auth_unbind"  
  
  devise_for :users, :path => "account"
  resources :users, :path => "u", :only => :show
  
  match "n:id" => "topics#node", :as => :node_topics
  match "t/last" => "topics#recent", :as => :recent_topics
  resources :topics, :path => "t" do
    member do
      post :reply
    end
    collection do
      get :search
      get :feed
    end
  end
  resources :replies, :path => "r"
  resources :photos do
    collection do
      get :tiny_new
    end
  end

  namespace :cpanel do 
    root :to => "home#index"
    resources :replies
    resources :topics
    resources :nodes
    resources :sections
    resources :users
    resources :photos
  end  
end
