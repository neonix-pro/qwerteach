Rails.application.routes.draw do
  
  namespace :api do
    get 'profiles' => 'profiles#index'
    post 'profiles/show' => 'profiles#show'
    post 'profiles/save' => 'profiles#save'
    get 'profiles/find_level' => 'profiles#find_level'
  end
  
  namespace :api do
    get 'adverts' => 'adverts#index'
    post 'adverts/create' => 'adverts#create'
    post 'adverts/update' => 'adverts#update'
    post 'adverts/show' => 'adverts#show'
    post 'adverts/delete' => 'adverts#delete'
    post 'adverts/find_advert_prices' => 'adverts#find_advert_prices'
  end

  namespace :api do
    get 'find_topics' => 'find_topics#index'
    post 'find_topics' => 'find_topics#show'
  end

  namespace :api do
    get 'find_group_topics' => 'find_group_topics#show'
  end

  namespace :api do
    devise_scope :user do
      get 'session' => 'session#index'
      post 'session' => 'session#login'
    end
  end

  namespace :api do
    devise_scope :user do
      get 'registration' => 'registration#index'
      post 'registration' => 'registration#create'
    end
  end

  namespace :admin do
    resources :users
    resources :students
    resources :teachers
    resources :pictures
    resources :galleries
    resources :postulations
    resources :comments
    resources :postuling_teachers
    resources :lessons
    resources :topics
    resources :topic_groups
    resources :level
    resources :advert_prices
    resources :adverts
    resources :payments

    

    get "/user_conversation/:id", to: "users#show_conversation", as: 'show_conversation'
    
   
    # Gestion des serveurs BBB depuis l'admin
    resources :bigbluebutton_servers
    resources :bigbluebutton_recordings
    resources :bbb_rooms

    root to: "users#index"
  end
  resources "contact", only: [:new, :create]
    


  scope '/user/mangopay', controller: :payments do
  end

  scope '/user/mangopay', controller: :wallets do
    get "edit_wallet" => :edit_mangopay_wallet
    put "edit_wallet" => :update_mangopay_wallet
    get "index_wallet" => :index_mangopay_wallet
    get "load-wallet" => :direct_debit_mangopay_wallet
    put "direct_debit" => :load_wallet
    get "transactions" => :transactions_mangopay_wallet
    get "card_info" => :card_info
    get "card_registration" => :card_registration
    put "send_card_info" => :send_card_info
    get 'bank_accounts' => :bank_accounts
    put 'update_bank_accounts' => :update_bank_accounts
    get 'payout' => :payout
    put 'make_payout' => :make_payout
    put 'desactivate_bank_account/:id' => :desactivate_bank_account, as: 'desactivate_bank_account'
  end
  # :omniauth_callbacks => "users/omniauth_callbacks",
  devise_for :users, :controllers => { :registrations=> "registrations"}
  devise_for :teachers, :controllers => {:registrations => "registrations"}
  get "/auth/:action/callback",
      :to => "users/omniauth_callbacks",
      :constraints => { :action => /google_oauth2|facebook/ }
  
  resources :users, only: [:update]
  
  get 'dashboard' => 'dashboards#index', :as => 'dashboard'
  get 'featured_reviews' => 'reviews#featured_reviews'

  resources :users, :only => [:show] do
    resources :require_lesson
    put '/request_lesson/payment' => 'request_lesson/payment'
    get '/request_lesson/process_payin' => 'request_lesson/process_payin'
    resources :request_lesson
    resources :reviews, only: [:index, :create, :new]
  end
  get '/both_users_online' => 'users#both_users_online', :as => 'both_users_online'
  authenticated :user do
    root 'pages#index'
  end
  resources :topics do
    get :autocomplete_topic_title, :on => :collection
  end
  match "/profs/" => "users#profs_by_topic", as: :profs, via: :post
  match "/profs/:topic" => "users#index", :as => :profs_by_topic, :via => [:get]
  get "/profs" => "users#index"

  unauthenticated :user do
    devise_scope :user do
      get "/" => "pages#index"
    end
  end
  resources :galleries, only: [:update, :edit, :show]
  resources :pictures, only: [:new, :destroy, :show]
  resources :degrees
  resources :notifications
  get "/notifications/unread/" => "notifications#number_of_unread"

  resources :adverts do
    resources :advert_prices
  end

  get '/adverts_user/:user_id', to: 'adverts#get_all_adverts', as: 'get_all_adverts'

  get "/pages/*page" => "pages#show", as: :pages

  get '/become_teacher/accueil' => "pages#devenir-prof"
  get '/index' => "pages#index"
  resources :become_teacher
  resources :conversations, only: [:index, :show, :delete] do
    member do
      post :reply
      post :mark_as_read
      post :trash
      post :mark_as_unread
      post :untrash
    end
  end
  match 'mailbox' => 'conversations#index', :as => 'messagerie', via: :get
  match 'mailbox/:mailbox' => 'conversations#index', :as => 'mailbox', via: :get
  post 'mailbox/search' => 'conversations#search'

  #Permet affichage facture
  get "/payments/index" => "payments#index"
  
  #post "lessons/:teacher_id/require_lesson", to: "lessons#require_lesson", as: 'require_lesson'
  resources :lessons do
    get 'accept_lesson' => :accept_lesson
    get 'refuse_lesson' => :refuse_lesson
    get 'cancel_lesson' => :cancel_lesson
    
    resources :payments do
      resources :pay_postpayments
    end
    post "create_postpayment" => "payments#create_postpayment"
    get "edit_postpayment/:payment_id" => "payments#edit_postpayment", as: 'edit_postpayment'
    post "edit_postpayment/:payment_id" => "payments#send_edit_postpayment", as: 'send_edit_postpayment'

    post "bloquerpayment" => "payments#bloquerpayment"
    post "debloquerpayment" => "payments#debloquerpayment"
    post "payerfacture/:payment_id" => "payments#payerfacture", as: 'payerfacture'
  end
  match '/cours' =>'lessons#index', :as => 'cours', via: :get
  match '/cours/recus'=>'lessons#received', :as => 'cours_recus', via: :get
  match '/cours/donnes'=>'lessons#given', :as => 'cours_donnes', via: :get
  match '/cours/historique'=>'lessons#history', :as => 'cours_historique', via: :get
  match '/cours/pending'=>'lessons#pending', :as => 'cours_pending', via: :get

  resources :messages, only: [:new, :create, ]
  post "/typing" => "messages#typing"
  post "/seen" => "messages#seen"
  get "/level_choice" => "adverts#choice"
  get "/topic_choice" => "adverts#choice_group"
  post "conversation/show_min" => "conversations#find"
  get "conversation/show_min/:conversation_id" => "conversations#show_min"

  # BBB rooms et recordings
  bigbluebutton_routes :default, :only => 'rooms', :controllers => {:rooms => 'bbb_rooms'}
  resource :bbb_rooms do
    get "/room_invite/:user_id" => "bbb_rooms#room_invite", as: 'room_invite'
    get "/end_room/:room_id" => "bbb_rooms#end_room", as: 'end_room'
  end
  bigbluebutton_routes :default, :only => 'recordings', :controllers => {:rooms => 'bbb_recordings'}

  mount Resque::Server, :at => "/resque"

  #root to: 'pages#index'
end
