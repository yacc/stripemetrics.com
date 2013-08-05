class LostRevenueMetric < Metric

  def data
    @data ||= self.user.failed_charge_volume_trend.monthly
  end

  def setup_description
    self.name = "Lost Revenue"
    self.desc = "Revenue lost because of failed charges"
    self.unit = 'dollars'
  end

end