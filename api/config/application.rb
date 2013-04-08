$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'server'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'
require 'grape'
require 'warden'

Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('../initializers/*.rb', __FILE__)].each do |f|
  require f
end

autoload :User, File.expand_path('models/user.rb')

# Dir[File.expand_path('../../models/*.rb', __FILE__)].each do |f|
#   autoload f
# end

Dir[File.expand_path('../../server/*.rb', __FILE__)].each do |f|
  require f
end
