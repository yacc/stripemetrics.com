if File.exist?('/home/deploy/environment.yml')
  redis = YAML.load(IO.read('/home/deploy/environment.yml'))
else
  redis = { 
              'STRIPEMETRICS_REDIS_HOST'=> 'localhost',
              'STRIPEMETRICS_REDIS_PORT' => '6379'
          }
end  

redis_con = Redis.new redis
$rollout = Rollout.new(redis_con)

$rollout.define_group(:admin) do |user|
  user.admin?
end