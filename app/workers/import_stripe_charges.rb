class ImportStripeCharges
	@queue = :stripe_import_queue

	def self.perform(user_id,start_date,end_date)
		worker = Stripe::Import::Charges.new(user_id,{start_date: start_date,end_date: end_date}).run
	end
	
end

