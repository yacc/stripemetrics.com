class AcquisitionTrend	
	@queue = :trend_queue

	def self.perform(user_id)
		report = Report::BasicTrends.new(user_id)
		report.generate
	end
end