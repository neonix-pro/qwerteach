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


  scope '/user/mangopay', controller: :payments do
  end

  scope '/user/mangopay', controller: :wallets do
    get "edit_wallet" => :edit_mangopay_wallet
    put "edit_wallet" => :update_mangopay_wallet
    get "index_wallet" => :index_mangopay_wallet
    get "direct_debit" => :direct_debit_mangopay_wallet
    put "direct_debit" => :send_direct_debit_mangopay_wallet
    get "transactions" => :transactions_mangopay_wallet
    get "card_info" => :card_info
    put "send_card_info" => :send_card_info
    get 'bank_accounts' => :bank_accounts
    put 'update_bank_accounts' => :update_bank_accounts
    get 'payout' => :payout
    put 'make_payout' => :send_make_payout
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  as :user do
    get 'users/edit_pwd' => 'registrations#pwd_edit', :as => 'edit_pwd_user_registration'
  end
  get 'dashboard' => 'dashboards#index', :as => 'dashboard'

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

  match '/profs/:topic' => 'users#index', :as => 'profs_by_topic', via: :get
  match '/profs' => 'users#index', :as => 'profs', via: :get

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

  get "/pages/*page" => "pages#show"
  get '/become_teacher/accueil' => "pages#devenir-prof"
  get '/index' => "pages#index"
  resources :become_teacher
  resources :conversations, only: [:index, :show, :destroy] do
    member do
      post :reply
      post :mark_as_read
    end
  end

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
