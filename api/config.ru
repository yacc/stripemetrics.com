require File.expand_path('../config/environment', __FILE__)

logger = Logger.new("log/#{ENV['RACK_ENV']}_api.log")
use Rack::CommonLogger, logger

run Stripemetrics::Api
