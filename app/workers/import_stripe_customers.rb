class ImportStripeCustomers
  @queue = :stripe_customer_import_queue

  def self.perform(user_id,options = {})

    begin
      offset         = 0
      imported       = 0
      count          = options["count"]  || 100
      user           = User.find(user_id)
      token          = user.token
      newest_import  = nil
      start_time     = Time.now

      director = user.import_directors.where(_type:"CustomerImportDirector").first
      last_processed = director.last_processed_ts || 1301355794
      import = director.imports.create(_type:"CustomerImport",status:'processing')

      begin
        customers = Stripe::Customer.all({:count => count, :offset => offset},token)
        newest_import = customers.data.first.created if newest_import.nil?
        customers.data.each do |cust|

          record = ::Customer.where(stripe_id:cust.id).first
          user.customers << ::Customer.create(Customer.from_stripe(cust.as_json)) if record.nil? 

          imported += 1
          print "."
        end
        last_date = customers.data.last.created
        offset += count
        print "-> #{last_date}\n"
      end while (last_date > last_processed) 

      import.update_attributes(status:'success',time:(start_time-Time.now).to_i,count:imported)
      director.update_attributes(last_ran_at: Time.now, last_processed_ts: newest_import)
    end

  end
  
end
