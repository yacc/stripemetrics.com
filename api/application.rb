$:.unshift File.join(__FILE__, "..","config")
require 'sinatra/base'
require 'grape'
require 'bundler/setup'
require 'mongoid'
require File.join(File.dirname(__FILE__), 'configuration')


module Stripemetrics

  class Api < Grape::API

    version 'v1', :using => :header, :vendor => 'stripemetrics'
    format :json

    helpers do

      def authenticate!
        error!('Unauthorized. Invalid token.', 401) unless current_user
      end

      def current_user
        user_token = params[:token]
        token = ApiKey.where(:access_token => user_token).first
        if token #TODO :&& !token.expired?
          @current_user = User.find(token.user_id)
        else
          false
        end
      end

    end

    namespace :imports do

      desc "Return a list of my imports."
      get '/' do
        Import.all.limit(20)
      end

    end

    namespace :auth do
   
      desc "Creates and returns access_token if valid login"
      params do
        requires :login, :type => String, :desc => "Email address"
        requires :password, :type => String, :desc => "Password"
      end
      post :login do
        user = User.find_by_email(params[:login].downcase)
        if user && user.authenticate(params[:password])
          key = ApiKey.create(:user_id => user.id)
          {:token => key.access_token}
        else
          error!('Unauthorized.', 401)
        end
      end
   
      desc "Returns pong if logged in correctly"
      params do
        requires :token, :type => String, :desc => "Access token."
      end
      get :ping do
        authenticate!
        { :message => "pong" }
      end
    end

  end    
end