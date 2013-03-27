class ImportStripeCharges
	@queue = :stripe_import_charge_queue

	def self.perform(user_id,options = {})

    offset         = 0
    count          = options["count"]  || 100
    start_date     = options["start_date"] ?  Time.parse(options["start_date"]).to_i : 2.weeks.ago.to_i
    user           = User.find(user_id)
    token          = user.token
    print "-> Start Charges Import for #{user.id} from #{start_date} to present\n"

    begin
      charges = Stripe::Charge.all({:count => count, :offset => offset},token)
      charges.data.each do |ch|
            charge = ch.as_json.except("card","fee_details") # storing the minimum
            record = ::Charge.where(stripe_id:ch.id).first
            charge["stripe_id"] = ch.id
            user.charges << ::Charge.create(charge) if record.nil? 
            print "."
      end
      last_date = charges.data.last.created
      offset += count
      print "-> #{last_date}\n"
    end while (last_date > start_date) 
  end
  
end