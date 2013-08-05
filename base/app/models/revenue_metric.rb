class RevenueMetric < Metric

  def data
    @data ||= self.user.paid_charge_volume_trend.monthly
  end

  def setup_description
    self.name = "Revenue"
    self.desc = "Revenue generated from successfull charges"
    self.unit = 'dollars'
  end

end