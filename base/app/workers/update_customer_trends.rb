require 'resque/plugins/lock'

class UpdateCustomerTrends	
  extend Resque::Plugins::Lock

  @queue = :customer_trend_queue

  def self.perform(user_id)
    user           = User.find(user_id)
    user.trends.where(source:'customers') do |trend|
      trend.aggregate!    
    end    
  end

end