$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'server'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'
require 'grape'
require 'warden'

Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('../initializers/*.rb', __FILE__)].each do |f|
  require f
end

Dir[File.expand_path('../../models/*.rb', __FILE__)].each do |f|
  model = File.basename(f,".*").split('_').collect(&:capitalize).join
  autoload model, f
end

Dir[File.expand_path('../../concerns/*.rb', __FILE__)].each do |f|
  concern = File.basename(f,".*").split('_').collect(&:capitalize).join
  autoload concern, f
end

Dir[File.expand_path('../../presenters/*.rb', __FILE__)].each do |f|
  presenter = File.basename(f,".*").split('_').collect(&:capitalize).join
  autoload presenter, f
end

Dir[File.expand_path('../../workers/*.rb', __FILE__)].each do |f|
  workers = File.basename(f,".*").split('_').collect(&:capitalize).join
  autoload workers, f
end

Dir[File.expand_path('../../entities/*.rb', __FILE__)].each do |f|
  require f
end

Dir[File.expand_path('../../server/*.rb', __FILE__)].each do |f|
  require f
end
