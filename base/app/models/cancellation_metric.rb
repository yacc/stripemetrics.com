class CancellationMetric < Metric

  def data
    @data ||= self.user.cancellation_trend.monthly
  end

  def setup_description
    self.name = "Cancellations"
    self.desc = "Number of customers that have cancelled their subscription"
    self.unit = 'count'
  end

end