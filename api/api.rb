require 'grape'

class API < Grape::API

  get "/" do
    Thing.find :all
  end

  post "/" do
    # All parameters will be stored in the model
    thing = Thing.new params

    if thing.save
      { thingId: thing.id }
    else
      error!({ errors: thing.errors.messages }, 403)
    end
  end

end



require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'mongoid'
require 'json'

class App < Sinatra::Base
    configure do
        if FileTest.exist?('/home/dotcloud/environment.json')
            env = JSON.parse(File.read('/home/dotcloud/environment.json'))
            set :host, env['DOTCLOUD_DB_MYSQL_HOST']
            set :port, env['DOTCLOUD_DB_MYSQL_PORT']
            set :login, env['DOTCLOUD_DB_MYSQL_LOGIN']
            set :password, env['DOTCLOUD_DB_MYSQL_PASSWORD']
            set :appname, env['DOTCLOUD_PROJECT']
        else
            set :host, 'localhost'
            set :port, '3306'
            set :login, 'root'
            set :password, 'root'
            set :appname, 'test'
        end

        set :dbname, 'test'
        $db = Mysql.connect(settings.host, settings.login, settings.password, settings.dbname, settings.port)
    end

    get '/' do
        html = '<div id="content" data-stack="ruby" data-appname="' + settings.appname + '">Hello World, from Sinatra!</div>'
        html += '<script type="text/javascript" src="http://helloapp.dotcloud.com/inject.min.js"></script>'
    end
end


require 'sinatra/base'
# require 'sinatra/contrib'
require 'mongoid'
require 'bundler/setup'
require 'pry'
require 'sample_app_config'
require 'routes'

class StripemetricsAPI < Sinatra::Base

end