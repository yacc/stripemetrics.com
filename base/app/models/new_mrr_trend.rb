class NewMrrTrend < Trend
  include NewMrrAgregation

  def data_source
    @data_source ||= self.user.charges  
  end

  def refresh!
    self.monthly = refresh_monthly
    self.name    = "New MRR"
    self.save
  end

end
