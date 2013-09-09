require 'resque/plugins/lock'

class UpdateChargeTrends  
  extend Resque::Plugins::Lock

  @queue = :charge_trend_queue

  def self.perform(user_id)
    user           = User.find(user_id)

    trend = (user.paid_charge_count_trend.nil? ? user.create_paid_charge_count_trend : user.paid_charge_count_trend)
    trend.refresh!

    trend = (user.failed_charge_count_trend.nil? ? user.create_failed_charge_count_trend : user.failed_charge_count_trend)
    trend.refresh!

    trend = (user.paid_charge_volume_trend.nil? ? user.create_paid_charge_volume_trend : user.paid_charge_volume_trend)
    trend.refresh!

    trend = (user.failed_charge_volume_trend.nil? ? user.create_failed_charge_volume_trend : user.failed_charge_volume_trend)
    trend.refresh!

    # metric2.0 trends
    trend = (user.booking_trend.nil? ? user.create_booking_trend : user.booking_trend)
    trend.refresh!
    trend = (user.new_mrr_trend.nil? ? user.create_new_mrr_trend : user.new_mrr_trend)
    trend.refresh!

  end
end