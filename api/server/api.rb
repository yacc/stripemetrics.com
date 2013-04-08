require 'sinatra/base'
require 'grape'

module Stripemetrics

  class Api < Grape::API

    version 'v1', :using => :header, :vendor => 'stripemetrics'
    format :json


    use Rack::Session::Cookie, :secret => "superSuperSuperSecretKeyKey!!"
    use Warden::Manager do |manager|
      manager.default_strategies :password, :api_token
      manager.failure_app = Stripemetrics::Api
    end
    

    namespace :imports do

      desc "Return a list of my imports."
      get '/' do
        Import.all.limit(20)
      end

    end

    namespace :auth do
   
      desc "Creates and returns access_token if valid credentials"
      post :login do
        user = env['warden'].authenticate!(:password)
        {:token => user.api_token}
      end
   
      desc "Returns pong if logged in correctly"
      get :ping do
        user = env['warden'].authenticate!(:api_token)
        { :message => "pong" }
      end
    end

  end    
end