Homeland::Application.routes.draw do
  

  resources :notes
  match "/uploads/*path" => "gridfs#serve"
  root :to => "topics#index"
  # match "login", :to => 'home#login'
  # match "login_create", :to => 'home#login_create'
	match "auth/:provider/callback", :to => "home#auth_callback"
  # match 'logout', :to => 'home#logout'
  # match 'register', :to => 'users#new'
  # match 'setting', :to => 'users#setting', :as => 'setting'
  # match 'setting/password', :to => 'users#password', :as => 'password'
  
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
