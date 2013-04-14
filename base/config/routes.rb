Stripemetrics::Application.routes.draw do
	
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin'                  => 'sessions#new',     :as => :signin
  match '/signout'                 => 'sessions#destroy', :as => :signout
  match '/auth/failure'            => 'sessions#failure'

  match 'quickstart'          => 'home#quickstart',:as => :quickstart
  match 'faq'                 => 'home#faq',:as => :faq
  match 'pricing'             => 'home#pricing',:as => :pricing

  match 'account'              => 'users#edit',   :as => :account
  match 'cancel'               => 'users#destroy',   :as => :cancel
  match 'billing'              => 'account#billing',   :as => :billing

  match 'dashboard'        => 'dashboard#index',:as => :dashboard

  match 'jobs'                     => 'jobs#index',      :as => :jobs      
  match 'jobs/:action'             => 'jobs#action'

  root :to => "home#quickstart"
  resources :users, :only => [:index, :show, :edit, :update ]


end
