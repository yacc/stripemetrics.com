class AcquisitionMetric < Metric

  def refresh!
    return if self.user.acquisition_trend.monthly.empty?
    self.this_month = self.user.acquisition_trend.monthly.last[1]
    self.reset!
    historical_data_size = self.user.acquisition_trend.monthly.size

    if historical_data_size >= 2
      self.last_month = self.user.acquisition_trend.monthly[-2][1]
      if historical_data_size >= 6
        last_six_month_data = self.user.acquisition_trend.monthly[-6..-1]
        self.change     = relative_change(last_six_month_data)
        self.tsm_avrg   = tsm_average(last_six_month_data)
      end
    end  

    self.name = "Aquisition"
    self.desc = "New Customers"
    self.save
  end

  def reset!
    self.last_month = nil
    self.change     = nil
    self.tsm_avrg   = nil      
  end

  def relative_change(data)
    this_month = data.last[1].to_f
    last_month = data[-2][1].to_f
    change = (this_month - last_month)
    (change / this_month)
  end


  def tsm_average(data)
    num_periods    = data.size.to_f
    starting_value = data.first[1].to_f  
    ending_value   = data.last[1].to_f  
    ((ending_value/starting_value)**(1./num_periods))-1
  end

end