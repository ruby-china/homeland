Homeland::Application.routes.draw do
  

  resources :notes
  match "/uploads/*path" => "gridfs#serve"
  root :to => "topics#index"  
  match "auth/:provider/callback", :to => "home#auth_callback"  
  
  devise_for :users
  resources :users, :only => :show
  
  match "topics/node_:id" => "topics#node", :as => :node_topics
  match "topics/recent" => "topics#recent", :as => :recent_topics
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
    resources :replies
    resources :topics
    resources :nodes
    resources :sections
    resources :users
    resources :photos
  end  
end
