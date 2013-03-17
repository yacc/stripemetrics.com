class CustomerAcquisitionTrend	
	@queue = :acquisition_trend_queue

	def self.perform(user_id,start_date,end_date)
		report = Report::BasicTrends.new(user_id,{start_date: start_date,end_date: end_date}).generate
	end
end