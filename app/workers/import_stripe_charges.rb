class ImportStripeCharges
	@queue = :stripe_charge_import_queue

	def self.perform(user_id,options = {})

    offset         = 0
    imported       = 0
    count          = options["count"]  || 100
    start_date     = options["start_date"] ?  Time.parse(options["start_date"]).to_i : 2.weeks.ago.to_i
    user           = User.find(user_id)
    token          = user.token
    start_time     = Time.now

    director = user.import_directors.where(_type:"ChargeImportDirector").first
    last_processed = director.last_processed_ts
    director.imports.create(_type:"ChargeImport",status:'processing')

    begin
      charges = Stripe::Charge.all({:count => count, :offset => offset},token)
      charges.data.each do |ch|

        charge = ch.as_json.except("card","fee_details")
        record = ::Charge.where(stripe_id:ch.id).first
        charge["stripe_id"] = ch.id
        user.charges << ::Charge.create(charge) if record.nil? 

        imported += 1
        print "."
      end
      last_date = charges.data.last.created
      offset += count
      print "-> #{last_date}\n"
    end while (last_date > start_date) 

    import.update_attributes(status:'success',time:(start_time-Time.now).to_i,count:imported)
    director.update_attributes(last_ran_at: Time.now, last_processed_ts: newest_import)

  end

end