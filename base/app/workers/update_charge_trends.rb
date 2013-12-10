require 'resque/plugins/lock'

class UpdateChargeTrends  
  extend Resque::Plugins::Lock

  @queue = :charge_trend_queue

  def self.perform(user_id)
    user = User.find(user_id)
    user.trends.where(source:'charges') do |trend|
      trend.aggregate!   
    end
  end

end