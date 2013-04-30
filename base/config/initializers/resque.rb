require 'resque_scheduler'
require 'resque_scheduler/server'

Resque.redis = ENV['DOTCLOUD_DATA_REDIS_URL'] || 'localhost:6379'
# test in the Rails console with Resque::Failure.count
 