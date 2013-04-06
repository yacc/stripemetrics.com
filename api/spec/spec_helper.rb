require File.join(File.dirname(__FILE__), '..', 'application')

require 'bundler'
Bundler.setup(:default, :test)
require 'sinatra/base'
require 'rspec'
require 'rack/test'

# expose models, spec and spec subdirectories
$:.unshift(File.join File.expand_path(File.dirname(__FILE__)), "..", "models")
$:.unshift(File.join File.expand_path(File.dirname(__FILE__)), "..", "spec/**")

# setup test environment
ENV['RACK_ENV'] = 'test'

def app
  Stripemetrics::Api
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end


