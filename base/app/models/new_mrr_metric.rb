class NewMrrMetric < Metric20
	include MetricCalculation

  def data_source
    @data_source ||= self.user.booking_trend.monthly
  end

  def setup_description
    self.name = "New MRR"
    self.desc = "MRR (mo recuring revenue) from new customers"
    self.unit = 'dollars'
  end

end