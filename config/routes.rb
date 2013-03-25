Stripemetrics::Application.routes.draw do
	
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin'                  => 'sessions#new',     :as => :signin
  match '/signout'                 => 'sessions#destroy', :as => :signout
  match '/auth/failure'            => 'sessions#failure'

  match 'home/quickstart'          => 'home#quickstart',:as => :quickstart
  match 'home/faq'                 => 'home#faq',:as => :faq
  match 'home/pricing'             => 'home#pricing',:as => :pricing

  match 'account'                  => 'account#index',   :as => :account
  match 'account/billing'          => 'account#billing',   :as => :billing

  match 'dashboard/:action'        => 'dashboard#action',:as => :dashboard

  match 'jobs'                     => 'jobs#index',      :as => :jobs      
  match 'jobs/:action'             => 'jobs#action'

  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]


end
