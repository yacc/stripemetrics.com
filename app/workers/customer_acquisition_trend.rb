class CustomerAcquisitionTrend	
	@queue = :acquisition_trend_queue

	def self.perform(user_id)
		report = Report::BasicTrends.new(user_id).generate
	end
end