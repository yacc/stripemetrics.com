class UpdateCustomerTrends	
  @queue = :customer_trend_queue

  def self.perform(user_id,options = {})
    user           = User.find(user_id)

    trend = (user.acquisition_trend.nil? ? user.create_acquisition_trend : user.acquisition_trend)
    trend.refresh!

    trend = (user.cancellation_trend.nil? ? user.create_cancellation_trend : user.cancellation_trend)
    trend.refresh!

  end

end