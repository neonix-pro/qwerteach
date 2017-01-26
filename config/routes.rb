Rails.application.routes.draw do
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
    resources :offer_prices
    resources :offers
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
      :controller => "users/omniauth_callbacks",
      :constraints => { :action => /google_oauth2|facebook/ }



  resources :users, only: [:update]

  get 'dashboard' => 'dashboards#index', :as => 'dashboard'
  get 'featured_reviews' => 'reviews#featured_reviews'

  resources :users, :only => [:show] do
    resources :require_lesson
    put '/lesson_requests/payment' => 'lesson_requests/payment'
    resources :lesson_requests, only: [:new, :create] do
      get 'topics/:topic_group_id', action: :topics, on: :collection
      get 'levels/:topic_id', action: :levels, on: :collection
      post :calculate, on: :collection
      get :credit_card_process, on: :collection
      get :bancontact_process, on: :collection
      post :create_account, on: :collection
    end
    resources :reviews, only: [:index, :create, :new]
  end
  get '/both_users_online' => 'users#both_users_online', :as => 'both_users_online'
  authenticated :user do
    root 'dashboards#index'
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

  resources :offers do
    resources :offer_prices
  end

  get '/offers_user/:user_id', to: 'offers#get_all_offers', as: 'get_all_offers'

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
    get 'accept' => :accept
    get 'refuse' => :refuse
    get 'cancel' => :cancel
    get 'pay_teacher'=>:pay_teacher
    get 'dispute'=>:dispute
    
    resources :payments do
      resources :pay_postpayments
    end
    post "create_postpayment" => "payments#create_postpayment"
    get "edit_postpayment/:payment_id" => "payments#edit_postpayment", as: 'edit_postpayment'
    post "edit_postpayment/:payment_id" => "payments#send_edit_postpayment", as: 'send_edit_postpayment'

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
  get "/conversation/show_more/:id/:page" => "conversations#show_more", as: 'conversation_show_page'
  get "/level_choice" => "offers#choice"
  get "/topic_choice" => "offers#choice_group"
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
