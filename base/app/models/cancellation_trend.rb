class CancellationTrend < Trend

  def refresh!
    self.daily   = refresh_daily
    self.weekly  = refresh_weekly
    self.monthly = refresh_monthly
    self.start_date = self.daily[0][0] unless self.daily.nil? || self.daily[0].nil?
    self.name    = "New Customers"
    self.save
  end

  def refresh_daily
    Customer.collection.aggregate([match,project,groupby("day")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["day"]).days).to_i*1000,data["count"]]
    end.sort_by{|k|k[0]}
  end

  def refresh_weekly
    Customer.collection.aggregate([match,project,groupby("week")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["week"]).weeks).to_i*1000, data["count"] ]
    end.sort_by{|k|k[0]}
  end

  def refresh_monthly
    Customer.collection.aggregate([match,project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, data["count"] ]
    end.sort_by{|k|k[0]}
  end

  private

  def match
    {
      "$match" => { "canceled_at" => {"$ne" => nil},"user_id" => self.user_id }
    }
  end

  def project
    {"$project" => 
      {
        "customers" => 1,
        "year"    => { "$year"  => "$canceled_at"}, 
        "month"   => { "$month" => "$canceled_at"},
        "week"    => { "$week"  => "$canceled_at"}, 
        "day"     => { "$dayOfYear" => "$canceled_at"} 
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

