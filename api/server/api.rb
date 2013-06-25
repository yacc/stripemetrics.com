module Stripemetrics

  class Api < Grape::API

    version 'v1', :vendor => 'stripemetrics'
    format :json

    use Rack::Session::Cookie, :secret => "superSuperSuperSecretKeyKey!!"
    use Warden::Manager do |manager|
      manager.default_strategies :password, :api_token
      manager.failure_app = Stripemetrics::Api
    end
    
    # ============================= IMPORTS =======================================
    namespace :imports do
      desc "Forces refresh of your Stripe data."
      post :refresh do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "refreshing data for #{current_user.email}"
        imports = current_user.refresh_data
        type = :default
        {:message => 'Imports have been scheduled.'}
      end
    end

    # ============================= METRICS =======================================
    namespace :metrics do
      desc "Forces refresh of your Stripe data."
      get '/' do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all metrics for #{current_user.email}"
        metrics = Metric.where(user_id:current_user.id) #where(_type is within [metric1., metric2 etc ...])
        type = :default
        present metrics, with: Stripemetrics::Entities::Metric, type: type
      end
      desc "Forces refresh of your Stripe Metrics."
      post :refresh do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "refreshing metrics for #{current_user.email}"
        imports = current_user.refresh_metrics
        type = :default
        {:message => 'Metrics have been refreshed.'}
      end
    end

    # ============================= AUTH =======================================
    namespace :auth do
      desc "Creates and returns access_token if valid credentials"
      post :tokens do
        Grape::API.logger.info "tokens"
        env['warden'].authenticate :password
        error! "Unauthorized", 401 unless env['warden'].user
        {:token => env['warden'].user.api_token}
      end  
      desc "Returns access_token if valid credentials"
      get :login do
        Grape::API.logger.info "login"
        env['warden'].authenticate :password
        error! "Unauthorized", 401 unless env['warden'].user
        {:token => env['warden'].user.api_token}
      end  
      desc "Returns pong if logged in correctly"
      get :ping do
        Grape::API.logger.info "user is pinging ..."
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        { :message => "pong #{current_user.email}" }
      end
    end

  end    
end