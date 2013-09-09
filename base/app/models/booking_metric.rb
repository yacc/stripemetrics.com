class BookingMetric < Metric20
	include MetricCalculation

  def data_source
    @data_source ||= self.user.booking_trend.monthly
  end

  def setup_description
    self.name = "Booking"
    self.desc = "Booking $,000\'s (new custs)"
    self.unit = 'dollars'
  end

end