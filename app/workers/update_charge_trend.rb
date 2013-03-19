class UpdateChargeTrend  
  @queue = :charge_trend_queue

  def self.perform(user_id,options = {})
    start_date     = options[:start_date] ?  Time.parse(options[:start_date]).to_i : 2.weeks.ago.to_i
    user           = User.find(user_id)

    last_date = nil
    print "::Start analysing customers from today back to #{start_date}::\n"

    map = %Q{
        function() {
            day = Date.UTC(this.created.getFullYear(), this.created.getMonth(), this.created.getDate());
            emit({day: day, user_id: this.user_id}, {count: 1});
        }                
    }
    reduce = %Q{
        function(key, values) {
            var count = 0;

            values.forEach(function(v) {
                count += v['count'];
            });

            return {count: count};
        }
    } 

    byday = user.charges.map_reduce(map, reduce).out(inline: true)

    trend = if user.charge_trend.nil? 
        user.create_charge_trend(account: "sensrnet") 
    else
        user.charge_trend
    end
    trend.update_attributes(
        data: byday.collect{ |a| a["value"]["count"]},
        start_at: (byday.first["_id"]["day"].to_i),
        name: "Charges"
    )
    trend.save    

  end
end