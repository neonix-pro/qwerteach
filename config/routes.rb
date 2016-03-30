Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :galleries
    resources :levels
    resources :pictures
    resources :students
    resources :teachers
    resources :postulations
    resources :comments
    #resources :conversations
    #resources :messages
    #resources :receipts
    get "/user_conversation/:id", to: "users#show_conversation", as: 'show_conversation'

    root to: "users#index"
  end

  #custom controller qui permet d'éditer certaine sparties du user sans donner le password
  devise_for :users, :controllers => {:registrations => "registrations"}

  resources :users, :only => [:show, :index]

  authenticated :user do
    root 'pages#index'
  end

  unauthenticated :user do
    devise_scope :user do
      get "/" => "devise/sessions#new"
    end
  end
  resources :galleries
  resources :pictures
  resources :degrees

  resources :adverts do
    resources :advert_prices
  end

  resources :conversations, only: [:index, :show, :destroy] do
    member do
      post :reply
      post :mark_as_read
    end
  end
  resources :messages, only: [:new, :create]
  post "/typing" => "messages#typing"
  post "/seen" => "messages#seen"
  get "/level_choice" => "adverts#choice"
  get "/topic_choice" => "adverts#choice_group"
  post "conversation/show_min" => "conversations#find"
  get "conversation/show_min/:conversation_id" => "conversations#show_min"


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


  #root to: 'pages#index'
end
