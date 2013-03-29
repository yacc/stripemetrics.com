class UpdateChargeTrend  
  @queue = :charge_trend_queue

  def self.perform(user_id,options = {})
    user           = User.find(user_id)

    trend = (user.paid_charge_trend.nil? ? user.create_paid_charge_trend : user.paid_charge_trend)
    trend.refresh!

    trend = (user.failed_charge_trend.nil? ? user.create_failed_charge_trend : user.failed_charge_trend)
    trend.refresh!

  end
end