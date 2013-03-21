class UpdateChargeTrend  
  @queue = :charge_trend_queue

  def self.perform(user_id,options = {})

    start_date     = options[:start_date] ?  Time.parse(options[:start_date]).to_i : 2.weeks.ago.to_i
    user           = User.find(user_id)
    last_date      = nil
    print "::Start analysing customers from today back to #{start_date}::\n"


    trend = (user.paid_charge_trend.nil? ? user.create_paid_charge_trend : user.paid_charge_trend)
    trend.refresh!

    trend = (user.failed_charge_trend.nil? ? user.create_failed_charge_trend : user.failed_charge_trend)
    trend.refresh!

  end
end