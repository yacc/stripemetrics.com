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
      desc "Return a list of my imports.", {
        :object_fields => Stripemetrics::Entities::ImportDirector.documentation
      }
      get '/' do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        imports = current_user.import_directors
        type = :default
        present imports, with: Stripemetrics::Entities::ImportDirector, :type => type
      end
    end

    # ============================= AUTH =======================================
    namespace :auth do
      desc "Creates and returns access_token if valid credentials"
      post :tokens do
        env['warden'].authenticate :password
        error! "Unauthorized", 401 unless env['warden'].user
        {:token => env['warden'].user.api_token}
      end  
      desc "Returns access_token if valid credentials"
      get :login do
        env['warden'].authenticate :password
        error! "Unauthorized", 401 unless env['warden'].user
        {:token => env['warden'].user.api_token}
      end  
      desc "Returns pong if logged in correctly"
      get :ping do
        env['warden'].authenticate :api_token
        error! "Unauthorized", 401 unless current_user = env['warden'].user
        { :message => "pong #{current_user.email}" }
      end
    end

  end    
end