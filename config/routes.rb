Rails.application.routes.draw do

  resources :global_requests
  namespace :api, :defaults => { :format => 'json' } do
    get 'dashboard' => 'dashboards#index'

    get 'users/find_level' => 'users#find_level'
    put 'users/:id' => 'users#update'
    patch 'users/:id' => 'users#update'
    get 'profs' => 'users#index'
    get 'profs/:topic' => 'users#index'
    get 'users/:id' => 'users#show'
    get 'get_infos_for_detailed_prices_modal' => 'users#get_infos_for_detailed_prices_modal'

    get 'users/:user_id/lesson_requests/new' => 'lesson_requests#new'
    post 'users/:user_id/lesson_requests' => 'lesson_requests#create'
    put 'users/:user_id/lesson_requests/payment' => 'lesson_requests#payment'
    get 'users/:user_id/lesson_requests/bancontact_process' => 'lesson_requests#bancontact_process'
    get 'users/:user_id/lesson_requests/credit_card_process' => 'lesson_requests#credit_card_process'
    get 'users/:user_id/lesson_requests/topic_groups' => 'lesson_requests#topic_groups'
    get 'users/:user_id/lesson_requests/topics/:topic_group_id' => 'lesson_requests#topics'
    get 'users/:user_id/lesson_requests/levels/:topic_id' => 'lesson_requests#levels'
    post 'users/:user_id/lesson_requests/calculate' => 'lesson_requests#calculate'

    get 'wallets/get_total_wallet/:user_id' => 'wallets#get_total_wallet'
    put 'user/mangopay/edit_wallet' => 'wallets#update_mangopay_wallet'
    get 'user/mangopay/index_wallet' => 'wallets#index'
    get 'user/mangopay/load-wallet' => 'wallets#direct_debit_mangopay_wallet'
    put 'user/mangopay/direct_debit' => 'wallets#load_wallet'
    get 'user/mangopay/card_info' => 'wallets#card_info'
    put 'user/mangopay/update_bank_accounts' => 'wallets#update_bank_accounts'
    put 'user/mangopay/desactivate_bank_account/:id' => 'wallets#desactivate_bank_account'
    put 'user/mangopay/make_payout' => 'wallets#make_payout'
    get 'user/mangopay/payout' => 'wallets#payout'
    get 'user/mangopay/transactions_index' => 'wallets#transactions_index'

    get 'lessons' => 'lessons#index'
    get 'lessons/index_pagination' => 'lessons#index_pagination'
    get 'lessons/find_lesson_informations/:lesson_id' => 'lessons#find_lesson_informations'
    get 'lessons/:lesson_id/cancel' => 'lessons#cancel'
    put 'lessons/:id' => 'lessons#update'
    get 'lessons/:lesson_id/refuse' => 'lessons#refuse'
    get 'lessons/:lesson_id/accept' => 'lessons#accept'
    get 'lessons/:lesson_id/pay_teacher' => 'lessons#pay_teacher'
    get 'lessons/:lesson_id/dispute' => 'lessons#dispute'
    post 'messages' => 'messages#create'
    get 'conversations' => 'conversations#index'
    post 'conversations/:id/reply' => 'conversations#reply'
    get 'conversations/:id' => 'conversations#show'
    get 'conversation/show_more/:id/:page' => 'conversations#show_more'
    post 'users/:user_id/reviews' => 'reviews#create'
    
    get 'notifications' => 'notifications#index'
    get 'notification/infos/:sender_id' => 'notifications#get_notification_infos'
  end
  
  namespace :api, :defaults => { :format => 'json' } do
    get 'offers' => 'offers#index'
    get 'offers/:id' => 'offers#show'
    post 'offers' => 'offers#create'
    patch 'offers/:id' => 'offers#update'
    delete 'offers/:id' => 'offers#destroy'
    get 'topic_choice' => 'offers#choice_group'
    get 'level_choice' => 'offers#choice'
    get 'offers/new' => 'offers#new'
  end

  namespace :api, :defaults => { :format => 'json' } do
    get 'topics' => 'topics#get_all_topics'
    get 'topic_groups' => 'topic_groups#get_all_topic_groups'
  end

  namespace :api, :defaults => { :format => 'json' } do
    devise_scope :user do
      post 'sessions' => 'sessions#create'
      delete 'sessions' => 'sessions#destroy'
      post 'registrations' => 'registrations#create'
    end
  end 
  
  namespace :admin do
    resources :users do
      get 'new_comment' => :new_comment
      post 'unblock' => :unblock
      post 'become' => :become
    end
    resources :students
    resources :teachers do
      post 'deactivate' => :deactivate
      post 'reactivate' => :reactivate
      get 'inactive' => :inactive_teachers, on: :collection, as: :inactive
      get 'postuling' => :postuling_teachers, on: :collection, as: :postuling
    end
    resources :pictures
    resources :galleries
    resources :postulations do
      get "generate_text" => :generate_text
    end
    resources :comments
    resources :lessons, only: %i[index show] do
      get :export, on: :collection
    end
    resources :topics
    resources :topic_groups
    resources :level
    resources :offer_prices
    resources :offers
    resources :payments, except: [:new, :create]
    resources :reviews, only: [:index, :show, :destroy]
    resources :conversations, only: [:index, :show]
    resources :mailboxer_messages
    resources :masterclasses do
      get 'join' => "masterclasses#join"
    end

    get "/user_conversation/:id", to: "users#show_conversation", as: 'show_conversation'

    resources :disputes, except: [:new, :create, :edit, :update] do
      post 'resolve' => :resolve, on: :member
    end

    # Gestion des serveurs BBB depuis l'admin
    resources :bigbluebutton_servers
    resources :bigbluebutton_recordings
    resources :bbb_rooms
    get "banned_users" => "users#banned_users"

    root to: "home#index"
    namespace :reports do
      get '/' => 'lessons_reports#index', as: :lessons
      get '/clients' => 'clients_reports#index', as: :clients
      get '/teachers' => 'teachers_reports#index', as: :teachers
      get '/activity' => 'activity_reports#index', as: :activity
      get '/activity/details' => 'activity_reports#show', as: :activity_details
    end
    resources :global_requests, only: [:index, :show, :edit]
  end
  resources "contact", only: [:new, :create]
  post 'entretien_pedagogique' => 'contacts#entretien_pedagogique'


  scope '/user/mangopay', controller: :payments do
  end

  scope '/user/mangopay', controller: :wallets do
    get "edit_wallet" => :edit_mangopay_wallet
    put "edit_wallet" => :update_mangopay_wallet
    get "index_wallet" => :index
    get "index"=>:index
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
    get 'transactions_index' => :transactions_index
  end
  #:omniauth_callbacks => "users/omniauth_callbacks",
  devise_for :users, :controllers => { :registrations=> "registrations", :confirmations => "confirmations"}
  devise_for :teachers, :controllers => {:registrations => "registrations", :confirmations => "confirmations"}
  resources :onboarding

  devise_scope :user do
    get "/auth/:action/callback",
        :controller => "users/omniauth_callbacks",
        :constraints => { :action => /google_oauth2|facebook/ }
  end

  resources :users, only: [:update]

  get 'dashboard' => 'dashboards#index', :as => 'dashboard'
  get 'featured_reviews' => 'reviews#featured_reviews'
  get 'unapproved-teachers' => "users#unapproved_teachers"

  resources :users, :only => [:show] do
    get 'sign_up' => "users#sign_up_show", :as => 'sign_up_show'
    resources :require_lesson
    post '/lesson_requests/payment' => 'lesson_requests/payment'
    resources :lesson_requests, only: [:new, :create] do
      get 'topics/:topic_group_id', action: :topics, on: :collection
      get 'levels/:topic_id', action: :levels, on: :collection
      post :calculate, on: :collection
      get :credit_card_process, on: :collection
      get :bancontact_process, on: :collection
      post :create_account, on: :collection
      get :finish
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
  match "/profs/(:topic)" => "users#profs_by_topic", as: :profs, via: :post
  match "/profs/:topic" => "users#index", :as => :profs_by_topic, :via => [:get]
  get "/profs" => "users#index", as: :all_teachers

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
  get "faq(/:target(/:section))/" => "pages#faq", as: :faq
  get "static/:page/:version" => "pages#abtest", as: :abtest
  get "cours/:topic/:version" => "users#abtest", as: :users_abtest
  get "incoming/:target/:source" => "pages#marketing", as: :marketing

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

  get 'lessons/index_pagination' => "lessons#index_pagination"
  #post "lessons/:teacher_id/require_lesson", to: "lessons#require_lesson", as: 'require_lesson'
  resources :lessons do
    get 'accept' => :accept
    get 'refuse' => :refuse
    get 'cancel' => :cancel
    post 'pay_teacher'=>:pay_teacher
    get 'dispute'=>:dispute
    put :reschedule, on: :member

    resources :payments do
      collection do
        get :credit_card_complete
        get :bancontact_complete
      end
      resources :pay_postpayments
    end
    post "create_postpayment" => "payments#create_postpayment"
    get "edit_postpayment/:payment_id" => "payments#edit_postpayment", as: 'edit_postpayment'
    post "edit_postpayment/:payment_id" => "payments#send_edit_postpayment", as: 'send_edit_postpayment'

    post "payerfacture/:payment_id" => "payments#payerfacture", as: 'payerfacture'

  end

  resources :lesson_packs do
    post :change, action: :new, on: :collection
    post :confirm, on: :collection
    get :confirm, on: :member
    put :reject, on: :member
    put :approve, on: :member
    put :propose, on: :member
    get :payment, on: :member
    post 'pay/:payment_method', action: :pay, on: :member, as: :pay
    get 'finish/:payment_method', action: :finish_payment, on: :member, as: :finish_payment
  end

  get 'calendar_index/(:id)'=>"lessons#calendar_index"

  resources :lesson_proposals, only: [:new, :create], constraints: ->(request){ request.env["warden"].user(:user).try(:type) == 'Teacher' }, path_names: {new: 'new/(:id)'}

  match '/cours' =>'lessons#index', :as => 'cours', via: :get
  match '/cours/recus'=>'lessons#received', :as => 'cours_recus', via: :get
  match '/cours/donnes'=>'lessons#given', :as => 'cours_donnes', via: :get
  match '/cours/historique'=>'lessons#history', :as => 'cours_historique', via: :get
  match '/cours/pending'=>'lessons#pending', :as => 'cours_pending', via: :get

  resources :messages, only: [:new, :create, ]
  get "messages/count" => "messages#count"
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
    get "/masterclass/:id" => "bbb_rooms#masterclass_room", as: 'masterclass'
  end
  bigbluebutton_routes :default, :only => 'recordings', :controllers => {:rooms => 'bbb_recordings'}
  get 'demo_room', to: "bbb_rooms#demo_room", as: 'demo_room'
  get 'join_demo/:id', to: "bbb_rooms#join_demo", as: 'join_demo'

  get 'levels_by_topic/:id', to: "global_requests#levels_by_topic", as: 'levels_by_topic'

  resources :toolbox, only: [:index, :show], path_names: {new: 'show/:id'}

  mount Resque::Server, :at => "/resque"

  resources :interests
  resources :masterclass, only: [:index, :create], path_names: {create: 'create_masterclass'}

  #root to: 'pages#index'
end
