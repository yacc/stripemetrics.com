class AcquisitionTrend < Trend

  def refresh!
    self.daily   = daily
    self.weekly  = weekly
    self.monthly = monthly
    self.start_date = self.daily[0][0] unless self.daily.nil?
    self.name    = "New Customers"
    self.save
  end

  def daily
    Customer.collection.aggregate([project,groupby("day")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["day"]).days).to_i*1000,data["count"]]
    end.sort_by{|k|k[0]}
  end

  def weekly
    Customer.collection.aggregate([project,groupby("week")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["week"]).weeks).to_i*1000, data["count"] ]
    end.sort_by{|k|k[0]}
  end

  def monthly
    Customer.collection.aggregate([project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, data["count"] ]
    end.sort_by{|k|k[0]}
  end

  private

  def project
    {"$project" => 
      {
        "customers" => 1,
        "year"    => { "$year"  => "$created"}, 
        "month"   => { "$month" => "$created"},
        "week"    => { "$week"  => "$created"}, 
        "day"     => { "$dayOfYear" => "$created"} 
      }
    }   
  end

  def groupby(interval)
    case interval
    when "day"
      { "$group" =>
        { "_id" => {"year"=>"$year", "day"=>"$day"}, "count" => { "$sum" => 1 } } 
      }
    when "week"
      { "$group" =>
        { "_id" => {"year"=>"$year", "week"=>"$week"}, "count" => { "$sum" => 1 } } 
      }
    when "month"      
      { "$group" =>
        { "_id" => {"year"=>"$year", "month"=>"$month"}, "count" => { "$sum" => 1 } } 
      }
    end
  end
  
end

