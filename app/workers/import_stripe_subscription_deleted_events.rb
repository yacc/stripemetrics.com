class ImportStripeSubscriptionDeletedEvents
  @queue = :stripe_import_events_queue

  def self.perform(user_id,options = {})

    begin
      offset         = 0
      imported       = 0
      count          = options["count"]  || 100
      user           = User.find(user_id)
      token          = user.token
      last_processed = user.imports_summary.subscriptions_import_last_processed_ts
      newest_import  = nil

      if user.imports_summary.subscriptions_import_locked
        print "-> Skiping Subscriptions Canceled Events Import for #{user.id} b/c one is already running\n"
        return
      end
      user.imports_summary.subscriptions_import_locked = true
      user.imports_summary.save
      print "-> Start Events Import for #{user.id} from #{last_processed} to present\n"

      import = ::SubscriptionDeletedEventsImport.create(status:'processing')
      user.subscriptions_deleted_events_imports << import
      begin
        events = Stripe::Event.all({:count => count, :offset => offset,:type => 'customer.subscription.deleted'},token)
        newest_import = events.data.first.created if newest_import.nil?
        events.data.each do |ev|
          cust_id = ev.data["object"]["customer"]
          customer = ::Customer.where(stripe_id:ch.id).first
          customer.subscription.canceled_at = ev.created
          customer.subscription.save
          imported += 1
          print "."
        end
        last_date = events.data.last.created
        offset += count
        print "-> #{last_date}\n"
      end while (last_date > last_processed) 
      import.update_attributes(status:'success',time:time,count:imported)
      user.imports_summary.update_attributes(subscriptions_import_last_ran_at: Time.now, subscriptions_import_last_processed_ts: newest_import)            
    ensure
      user.imports_summary.subscriptions_import_locked = false
      user.imports_summary.save
    end

  end
  
end
