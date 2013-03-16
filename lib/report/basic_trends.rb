module Report
    class BasicTrends

        def initialize(options={})
            $stdout.sync   = (options[:verbose] ? true : false)
        end

        def generate
            last_date = nil
            print "::Start analysing customers from today back to #{@start_date}::"
            update_acquisition_trend
            # ::SubscriptionReport.with_attachement(@cust_csv_filename,@cust_csv_filepath).deliver
        end

        private

        def update_acquisition_trend
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
            byday = Customer.map_reduce(map, reduce).out(inline: true)

            aqu = Acquisition.where(account: "sensrnet").first_or_create
            aqu.update_attributes(
                data: byday.collect{ |a| a["value"]["count"]},
                start_at: (byday.first["_id"]["day"].to_i),
                name: "Acquisition"
            )
            aqu.save    
        end

    end
end 
