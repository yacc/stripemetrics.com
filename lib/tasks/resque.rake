###  start workers with 
## rake resque:work QUEUE='*'
require "resque/tasks"
task "resque:setup" => :environment