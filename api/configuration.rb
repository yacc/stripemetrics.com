require 'sinatra/base'
require 'bundler/setup'
require 'mongoid'

module Stripemetrics 
  class API < Sinatra::Base

    configure :development do
      Bundler.setup(:default, :assets, :development)
      set :environment, :development
      enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run
      Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
    end

    configure :test do
      Bundler.setup(:default, :test)
      set :environment, :test
      enable :sessions, :static, :inline_templates, :method_override, :raise_errors
      disable :run, :dump_errors, :logging
      Mongoid.load!(File.expand_path(File.join("config", "mongoid.yml")))
    end

    configure :production do
      Bundler.setup(:default, :production)
      set :environment, :production
      enable :sessions, :logging, :static, :inline_templates, :method_override, :dump_errors, :run

      env = JSON.parse(File.read('/home/dotcloud/environment.json'))
      set :host,     env['DOTCLOUD_DB_MONGODB_HOST']
      set :port,     env['DOTCLOUD_DB_MONGODB_PORT']
      set :login,    env['DOTCLOUD_DB_MONGODB_LOGIN']
      set :password, env['DOTCLOUD_DB_MONGODB_PASSWORD']
      set :appname,  env['DOTCLOUD_PROJECT'] + "_production"

      connection = Mongo::Connection.new(:host, :port)
      Mongoid.database = connection.db(:appname)
      Mongoid.database.authenticate(:login,:password)
    end

  end
end

