class ImportStripeCustomerDeletedEvents
  @queue = :stripe_cde_import_queue

  def self.perform(user_id,options = {})

    begin
      offset         = 0
      imported       = 0
      count          = options["count"]  || 100
      user           = User.find(user_id)
      token          = user.token
      newest_import  = nil
      start_time     = Time.now

      director = user.import_directors.where(_type:"CDEImportDirector").first
      last_processed = director.last_processed_ts
      director.imports.create(_type:"CDEImport",status:'processing')

      begin
        events = Stripe::Event.all({:count => count, :offset => offset,:type => 'customer.deleted'},token)
        newest_import = events.data.first.created if newest_import.nil?
        events.data.each do |ev|

          cust_id = ev.data["object"]["customer"]
          customer = ::Customer.where(stripe_id:ch.id).first
          customer.canceled_at =  ev.created
          customer.save
          customer.subscription.canceled_at = ev.created
          customer.subscription.save
          
          imported += 1
          print "."
        end
        last_date = events.data.last.created
        offset += count
        print "-> #{last_date}\n"
      end while (last_date > last_processed) 

      import.update_attributes(status:'success',time:(start_time-Time.now).to_i,count:imported)
      director.update_attributes(last_ran_at: Time.now, last_processed_ts: newest_import)
    end

  end
  
end
