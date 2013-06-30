Stripemetrics::Application.routes.draw do
	
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin'                  => 'sessions#new',     :as => :signin
  match '/signout'                 => 'sessions#destroy', :as => :signout
  match '/auth/failure'            => 'sessions#failure'

  # =============== HOME ============================================
  match 'quickstart'          => 'home#quickstart',:as => :quickstart
  match 'faq'                 => 'home#faq',       :as => :faq
  match 'about'               => 'home#about',     :as => :about

  # =============== USER ============================================
  match 'account'              => 'users#edit',               :as => :account
  match 'cancel'               => 'users#destroy',            :as => :cancel
  match '/users/update'        => 'users#update',             :as => :user_update
  match 'upgrade_from_trial'   => 'users#upgrade_from_trial', :as => :upgrade_from_trial
  match 'update_plan'          => 'users#update_plan',        :as => :update_plan

  # =============== PLANS ===========================================
  match 'plans'                => 'plans#index',   :as => :pricing
  match 'upgrading'            => 'plans#index_for_upgrading',   :as => :upgrading

  # =============== HOME ============================================

  # =============== OTHER ============================================
  match 'dashboard'        => 'dashboard#index',:as => :dashboard
  match 'trends'           => 'trends#index',:as => :trends
  match 'status'           => 'imports#index',:as => :status

  # match 'jobs'                     => 'jobs#index',      :as => :jobs      
  # match 'jobs/:action'             => 'jobs#action'

  root :to => "home#quickstart"
  resources :users, :only => [:index, :show, :edit, :update ]

  mount Resque::Server, :at => "/rescousse"  

end
