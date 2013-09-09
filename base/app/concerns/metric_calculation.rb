module MetricCalculation
  extend ActiveSupport::Concern

  LAST_MONTH_INDEX = -3
  THIS_MONTH_INDEX = -2

  def refresh!
    return if data_source.size < 3
    self.reset!
    self.last_month = data_source[LAST_MONTH_INDEX][1]
    self.this_month = data_source[THIS_MONTH_INDEX][1]
    self.last_month_ts = Time.at(data_source[LAST_MONTH_INDEX][0]/1000).strftime("%Y-%m-%d")
    self.this_month_ts = Time.at(data_source[THIS_MONTH_INDEX][0]/1000).strftime("%Y-%m-%d")
    historical_data_source_size = data_source.size

    if historical_data_source_size >= 6
      last_six_month_data_source = data_source[-6..-1]
      self.change     = relative_change(last_six_month_data_source)
      self.tsm_avrg   = tsm_average(last_six_month_data_source)
    end

    setup_description      
    self.save
  end

  def reset!
    self.this_month = nil
    self.last_month = nil
    self.this_month_ts = nil
    self.last_month_ts = nil
    self.change     = nil
    self.tsm_avrg   = nil      
  end

  def relative_change(data_source)
    this_month = data_source[THIS_MONTH_INDEX][1].to_f
    last_month = data_source[LAST_MONTH_INDEX][1].to_f
    change = (this_month - last_month)
    (change / this_month)
  end

  def tsm_average(data_source)
    num_periods    = data_source.size.to_f
    starting_value = data_source.first[1].to_f  
    ending_value   = data_source.last[1].to_f  
    ((ending_value/starting_value)**(1./num_periods))-1
  end

end