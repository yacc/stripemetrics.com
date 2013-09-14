namespace :refresh do
  desc "refreshes all user's data from stripe"
  task :data => :environment do
      time_start = Time.now
      User.each do |user|
        user.refresh_data
      end
      puts "Finished refreshing user data in #{Time.now - time_start} seconds"
  end
  desc "refreshes all user's metrics"
  task :metrics => :environment do
      time_start = Time.now
      User.each do |user|
        user.refresh_metrics
      end
      puts "Finished refreshing user metrics in #{Time.now - time_start} seconds"
  end
  desc "refreshes all user's cohorts"
  task :cohorts => :environment do
      time_start = Time.now
      User.each do |user|
        user.refresh_cohorts
      end
      puts "Finished refreshing user cohorts in #{Time.now - time_start} seconds"
  end
  desc "refreshes new_mrr flag on charge"
  task :new_mrr => :environment do
      time_start = Time.now
      Charge.each do |charge|
        charge.update_attribute(:new_mrr,true) if charge.is_charge_from_new_customer? 
      end
      puts "Finished refreshing user cohorts in #{Time.now - time_start} seconds"
  end  
end
