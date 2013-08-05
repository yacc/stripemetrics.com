class AcquisitionMetric < Metric

  def data
    @data ||= self.user.acquisition_trend.monthly
  end

  def setup_description
    self.name = "New Customers"
    self.desc = "Number of new customers that joined this month"
    self.unit = 'count'    
  end

end