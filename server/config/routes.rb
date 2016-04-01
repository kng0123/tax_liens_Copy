Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations" }

  resources :liens, defaults: {format: :json}, only: [:index, :create, :show, :update] do
    collection { post :import }
    resources :receipts, only:[:index, :show, :create]
    resources :subsequents, only:[:index, :show, :create]
    # resources :todos, only: [:index, :create, :show, :update, :destroy]
  end

  resources :receipts, defaults: {format: :json}, only: [:show, :update, :create]
  resources :subsequents, defaults: {format: :json}, only: [:show, :update, :create]
  resources :subsequent_batch, defaults: {format: :json}, only: [:index, :show, :update, :create]
  resources :notes, defaults: {format: :json}, only: [:index, :show, :update, :create]
  resources :townships, defaults: {format: :json}, only: [:index]

  match '/app', :to => 'ttg#index', :via => [:get]
  match '/app/:lien', :to => 'ttg#index', :via => [:get]
  match '/app/:lien/:asdsad', :to => 'ttg#index', :via => [:get]
  match '/app/lien/item/:asdadsd', :to => 'ttg#index', :via => [:get]
  match '/app/lien/batch/:asdadsd', :to => 'ttg#index', :via => [:get]
  match '/lien/export_receipts', :to =>  'liens#export_receipts', :via =>[:get]
  match '/lien/export_liens', :to =>  'liens#export_liens', :via =>[:get]

  # config/routes.rb

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  root to: 'pages#index'
end
