require 'resque_scheduler'

if File.exist?('/home/deploy/environment.yml')
  redis = YAML.load(IO.read('/home/deploy/environment.yml'))
else
  redis = { 
              'STRIPEMETRICS_REDIS_HOST'=> 'localhost',
              'STRIPEMETRICS_REDIS_PORT' => '6379'
          }
end  

Resque.redis = "#{redis['STRIPEMETRICS_REDIS_HOST']}:#{redis['STRIPEMETRICS_REDIS_PORT']}"
# test in the Rails console with Resque::Failure.count
 