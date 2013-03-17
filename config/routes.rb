Stripemetrics::Application.routes.draw do
	
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin'                  => 'sessions#new',     :as => :signin
  match '/signout'                 => 'sessions#destroy', :as => :signout
  match '/auth/failure'            => 'sessions#failure'

  match 'jobs'                     => 'jobs#index',      :as => :jobs      
  match 'jobs/:action'             => 'jobs#action'

  match 'dashboard/:action'        => 'dashboard#action',:as => :dashboard

  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]


end
