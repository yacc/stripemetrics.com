class BookingTrend < Trend
  include ChargeVolumeAggregation

  def data_source
    @data_source ||= self.user.charges  
  end

  def refresh!
    self.monthly = refresh_monthly
    self.name    = "Booking"
    self.save
  end

end
