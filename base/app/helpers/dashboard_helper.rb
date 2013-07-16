module DashboardHelper

  def trailing_30_days_volume
    if current_user.paid_charge_volume_trend.monthly.empty?
      '<div class="icon-question-sign"></div>'
    else
      number_to_currency(current_user.paid_charge_volume_trend.monthly.last[1], precision: 0)
    end    
  end

  def trailing_30_days_volume_desc
    if current_user.paid_charge_volume_trend.monthly.empty? || current_user.paid_charge_volume_trend.monthly.size < 2
     'not enough data'
    else
      this_month = current_user.paid_charge_volume_trend.monthly.last[1]
      last_month = current_user.paid_charge_volume_trend.monthly[-2][1]
      if this_month < last_month
        "<i class=\"icon-arrow-down text-error\"> Monthly Revenue is down from #{ number_to_currency(last_month, precision: 0)}</i>"
      else  
        "<i class=\"icon-arrow-up text-success\"> Monthly Revenue is up from #{ number_to_currency(last_month, precision: 0)}</i>"                   
      end
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
    if current_user.acquisition_trend.monthly.empty? || current_user.acquisition_trend.monthly.size < 2
     'not enough data'
    else
      this_month = current_user.acquisition_trend.monthly.last[1]
      last_month = current_user.acquisition_trend.monthly[-2][1]
      if this_month < last_month
        "<i class=\"icon-arrow-down text-error\"> Monthly new users is down from #{last_month}</i>"
       else  
        "<i class=\"icon-arrow-up text-success\"> Monthly new users is up from #{last_month}</i>"
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
    if current_user.cancellation_trend.monthly.empty? || current_user.cancellation_trend.monthly.size < 2   
     'not enough data'
    else
      this_month = current_user.cancellation_trend.monthly.last[1]
      last_month = current_user.cancellation_trend.monthly[-2][1]
      if this_month < last_month
        "<i class=\"icon-arrow-down text-success\"> Monthly cancellation is down from #{last_month}</i>"
       else  
        "<i class=\"icon-arrow-up text-error\"> Monthly cancellation is up from #{last_month}</i>"
      end
    end
  end

  def trailing_30_failed_charges
    if current_user.failed_charge_volume_trend.monthly.empty?
      '<div class="icon-question-sign"></div>'
    else
      number_to_currency(current_user.failed_charge_volume_trend.monthly.last[1], precision: 0)
    end    
  end

  def trailing_30_failed_charges_desc
    if current_user.failed_charge_volume_trend.monthly.empty? || current_user.failed_charge_volume_trend.monthly.size < 2
      'not enough data'
    else
      this_month = current_user.failed_charge_volume_trend.monthly.last[1]
      last_month = current_user.failed_charge_volume_trend.monthly[-2][1]
      if this_month < last_month
        "<i class=\"icon-arrow-down text-success\"> Monthly failed charges is down from #{number_to_currency(last_month, precision: 0)}</i>"
       else  
        "<i class=\"icon-arrow-up text-error\"> Monthly failed charges is up from #{number_to_currency(last_month, precision: 0)}</i>"
      end
    end
  end

end
