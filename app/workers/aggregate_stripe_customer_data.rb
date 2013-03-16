class AggregateStripeCustomerData
	@queue = :aggregation_queue

	def self.perform(user_id)
		worker = Stripe::Aggregator.new(user_id).run
	end
	
end

