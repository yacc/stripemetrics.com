class AggregateStripeCustomerData
	@queue = :aggregation_queue

	def self.perform(user_id,start_date,end_date)
		worker = Stripe::Aggregator.new(user_id,{start_date: start_date,end_date: end_date}).run
	end
	
end

