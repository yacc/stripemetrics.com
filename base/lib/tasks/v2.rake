require 'json'

namespace :v2 do

  desc "exports users to file"
  task :export_users => :environment do
    time_start = Time.now
    users = []
    User.each{|user| users << user.as_json.except("c_at","stat","_id","api_token") }
    filename = "export_users_#{Time.now.strftime("%Y_%m_%d")}.json"
    filepath = File.join('/tmp',filename)
    open(filepath, 'w'){|ff| ff << users.to_json}
    puts "Export users to #{filepath} in #{Time.now - time_start} seconds"
  end

  desc "imports and creates users from file: rake v2:import_users['/tmp/foo.json']"
  task :import_users, [:filename]  => :environment do |t, args|
    time_start = Time.now
    users = JSON.parse(File.read(args[:filename]))
    users.each{|user| User.create! user }
    puts "Import and created new users from #{args[:filename]} in #{Time.now - time_start} seconds"
  end

end
