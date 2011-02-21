Homeland::Application.routes.draw do
  

  resources :notes
  match "/uploads/*path" => "gridfs#serve"
  root :to => "topics#index"
  match "login", :to => 'home#login'
  match "login_create", :to => 'home#login_create'
	match "auth/:provider/callback", :to => "home#auth_callback"
  match 'logout', :to => 'home#logout'
  match 'register', :to => 'users#new'
  match 'setting', :to => 'users#setting', :as => 'setting'
  match 'setting/password', :to => 'users#password', :as => 'password'
  resources :users
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

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
