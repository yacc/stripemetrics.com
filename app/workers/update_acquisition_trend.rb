class UpdateAcquisitionTrend	
	@queue = :acquisition_trend_queue

	def self.perform(user_id,options = {})
    start_date     = options[:start_date] ?  Time.parse(options[:start_date]).to_i : 2.weeks.ago.to_i
    user           = User.find(user_id)
    token          = user.token

    last_date = nil
    print "::Start analysing customers from today back to #{start_date}::"

    map = %Q{
        function() {
            day = Date.UTC(this.created_at.getFullYear(), this.created_at.getMonth(), this.created_at.getDate());
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

    byday = user.customers.map_reduce(map, reduce).out(inline: true)

    aqu = if user.acquisition_trend.nil? 
        user.create_acquisition_trend(account: "sensrnet") 
    else
        user.acquisition_trend
    end
    aqu.update_attributes(
        data: byday.collect{ |a| a["value"]["count"]},
        start_at: (byday.first["_id"]["day"].to_i),
        name: "Acquisition"
    )
    aqu.save    

  end
end