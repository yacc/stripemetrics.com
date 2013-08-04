module Stripemetrics

  class Api < Grape::API

    rescue_from :all
    version 'v1', :vendor => 'stripemetrics'
    format :json


    before do
        header['Access-Control-Allow-Origin'] = '*'
        header['Access-Control-Request-Method'] = '*'
    end

    use Rack::Session::Cookie, :secret => "superSuperSuperSecretKeyKey!!"
    use Warden::Manager do |manager|
      manager.default_strategies :password, :api_token
      manager.failure_app = Stripemetrics::Api
    end
    
    # ============================= IMPORTS =======================================
    namespace :imports do
      desc "Forces a refresh of all your Stripe data by scheduling new imports."
      post :refresh do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "refreshing data for #{current_user.email}"
        imports = current_user.refresh_data
        type = :default
        {:message => 'Imports have been scheduled.'}
      end
    end

    # ============================= LOST REVENUE =======================================
    namespace :lost_revenue do
      desc "Lists charges that have failed today (lost revenue)"
      get :today do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all charges that have failed for #{current_user.email}"
        charges = current_user.charges.where(paid:false).where(:created.gte => Time.new.beginning_of_day)
        type = :default
        present charges, with: Stripemetrics::Entities::FailedCharges, type: type
      end
      desc "Lists charges that have failed this week(lost revenue)"
      get :lastweek do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all charges that have failed for #{current_user.email}"
        charges = current_user.charges.where(paid:false).where(:created.gte => 1.week.ago)
        type = :default
        present charges, with: Stripemetrics::Entities::FailedCharges, type: type
      end
      desc "Lists charges that have failed this month(lost revenue)"
      get :lastmonth do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all charges that have failed for #{current_user.email}"
        charges = current_user.charges.where(paid:false).where(:created.gte => 1.month.ago)
        type = :default
        present charges, with: Stripemetrics::Entities::FailedCharges, type: type
      end
    end

    # ============================= CANCELLATIONS =======================================
    namespace :cancellations do
      desc "Lists customers that have canceled today"
      get :today do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all customers that have cancelled today for #{current_user.email}"
        customers = current_user.customers.where(:canceled_at.gte => Time.new.beginning_of_day)
        type = :default
        present customers, with: Stripemetrics::Entities::Customer, type: type
      end
      desc "Lists customers that have canceled since one week ago"
      get :lastweek do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all customers that have cancelled last week for #{current_user.email}"
        customers = current_user.customers.where(:canceled_at.gte => 1.week.ago)
        type = :default
        present customers, with: Stripemetrics::Entities::Customer, type: type
      end
      desc "Lists customers that have canceled since one month ago"
      get :lastmonth do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all customers that have cancelled last month for #{current_user.email}"
        customers = current_user.customers.where(:canceled_at.gte => 1.month.ago)
        type = :default
        present customers, with: Stripemetrics::Entities::Customer, type: type
      end
    end

    # ============================= METRICS =======================================
    namespace :metrics do
      desc "Displays metrics"
      get '/' do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        Grape::API.logger.info "listing all metrics for #{current_user.email}"
        metrics = Metric.where(user_id:current_user.id) #where(_type is within [metric1., metric2 etc ...])
        type = :default
        present metrics, with: Stripemetrics::Entities::Metric, type: type
      end
      desc "Forces refresh of your metrics."
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


    add_swagger_documentation :api_version => 'v1', :mount_path => 'doc', :hide_documentation_path => true

  end    
end
