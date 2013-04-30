require 'resque/plugins/lock'

class ImportStripeCustomerDeletedEvents
  extend Resque::Plugins::Lock

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

      director = user.cde_import_director
      last_processed = director.last_processed_ts || 1301355794 
      import = director.imports.create(_type:"CDEImport",status:'processing')

     begin
        events = Stripe::Event.all({:count => count, :offset => offset,:type => 'customer.deleted'},token)
        newest_import = events.data.first.created if newest_import.nil?
        events.data.each do |ev|
          cust_id = ev.data.object.id
          document = {canceled_at:ev.created, subscription:{canceled_at:ev.created}}
          customer = ::Customer.where(stripe_id:cust_id).find_and_modify({ "$set" => document}, { upsert:true,new:true })
          unless customer.nil?
            user.customers << customer
            imported += 1 
          end
        end
        offset += count
      end while (events && (events.data.last.created > last_processed)) 

      import.update_attributes(status:'success',time:(start_time-Time.now).to_i,count:imported)
      director.update_attributes(last_ran_at: Time.now, last_processed_ts: newest_import)
    end

  end
  
end
