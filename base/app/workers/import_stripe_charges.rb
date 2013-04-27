require 'resque/plugins/lock'

class ImportStripeCharges
  extend Resque::Plugins::Lock
  
	@queue = :stripe_charge_import_queue

	def self.perform(user_id,options = {})

    offset         = 0
    imported       = 0
    count          = options["count"]  || 100
    user           = User.find(user_id)
    token          = user.token
    start_time     = Time.now

    director = user.import_directors.where(_type:"ChargeImportDirector").first
    last_processed = director.last_processed_ts || 1301355794
    import = director.imports.create(_type:"ChargeImport",status:'processing')

    begin
      charges = Stripe::Charge.all({:count => count, :offset => offset},token)
      newest_import = charges.data.first.created if newest_import.nil?

      charges.data.each do |ch|

        record = ::Charge.where(stripe_id:ch.id).first
        user.charges << ::Charge.create(Charge.from_stripe(ch.as_json)) if record.nil? 

        imported += 1
        print "."
      end
      last_date = charges.data.last.created
      offset += count
      print "-> #{last_date}\n"
    end while (last_date > last_processed) 

    import.update_attributes(status:'success',time:(start_time-Time.now).to_i,count:imported)
    director.update_attributes(last_ran_at: Time.now, last_processed_ts: newest_import)

  end

end