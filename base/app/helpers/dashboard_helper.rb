module DashboardHelper

  def trailing_30_days_volume
    if current_user.paid_charge_volume_trend.monthly.empty?
      '<div class="icon-question-sign"></div>'
    else
      number_to_currency(current_user.paid_charge_volume_trend.monthly.last[1])
    end    
  end

  def trailing_30_days_volume_desc
    if current_user.paid_charge_volume_trend.monthly.empty?
     'not enough data'
    elsif current_user.paid_charge_volume_trend.monthly.size
      volume1 = current_user.paid_charge_volume_trend.monthly.last[1]
      volume2 = current_user.paid_charge_volume_trend.monthly[-1][1]
      if volume1 < volume2
        '<i class="icon-arrow-down text-error"> Monthly Charges is down</i>'
       else  
        '<i class="icon-arrow-up text-success"> Monthly Charges is up</i>'                   
      end
    else
      render "sparkline", :data   => @paid_charges.weekly.collect{|c| c[1]},
                          :div    => "paid-charges-montlhy-trend",
                          :title  => "Monthly Charges"      
    end
  end

  def trailing_30_days_acquisition
    if current_user.acquisition_trend.monthly.empty?
      '<div class="icon-question-sign"></div>'
    else
      current_user.acquisition_trend.monthly.last[1]
    end    
  end

  def trailing_30_days_acquisition_desc
    if current_user.acquisition_trend.monthly.empty?
     'not enough data'
    else
      acquisition1 = current_user.acquisition_trend.monthly.last[1]
      acquisition2 = current_user.acquisition_trend.monthly[-1][1]
      if acquisition1 < acquisition2
        '<i class="icon-arrow-down text-error"> Trailing 30 days Acquisition is down</i>'
       else  
        '<i class="icon-arrow-up text-success">  Trailing 30 days Acquisition is up</i>'                   
      end
    end
  end

  def trailing_30_days_cancellation
    if current_user.cancellation_trend.monthly.empty?
      '<div class="icon-question-sign"></div>'
    else
      current_user.cancellation_trend.monthly.last[1]
    end    
  end

  def trailing_30_days_cancellation_desc
    if current_user.cancellation_trend.monthly.empty?    
     'not enough data'
    else
      cancellation1 = current_user.cancellation_trend.monthly.last[1]
      cancellation2 = current_user.cancellation_trend.monthly[-1][1]
      if cancellation1 < cancellation2
        '<i class="icon-arrow-down text-success"> Trailing 30 days Cancelation is down</i>'
       else  
        '<i class="icon-arrow-up text-error">  Trailing 30 days Cancelation is up</i>'                   
      end
    end
  end

  def trailing_30_failed_charges
    if current_user.failed_charge_volume_trend.monthly.empty?
      '<div class="icon-question-sign"></div>'
    else
      number_to_currency(current_user.failed_charge_volume_trend.monthly.last[1])
    end    
  end

  def trailing_30_failed_charges_desc
    if current_user.failed_charge_volume_trend.monthly.empty?
      'not enough data'
    else
      volume1 = current_user.failed_charge_volume_trend.monthly.last[1]
      volume2 = current_user.failed_charge_volume_trend.monthly[-1][1]
      if volume1 < volume2
        '<i class="icon-arrow-down text-success"> Trailing 30 days Charges is down</i>'
       else  
        '<i class="icon-arrow-up text-error"> Trailing 30 days Charges is up</i>'                   
      end
    end
  end

end
