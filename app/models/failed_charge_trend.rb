class FailedChargeTrend < Trend

  def refresh!
    self.daily   = daily
    self.weekly  = weekly
    self.monthly = monthly
    self.start_date = daily[0][0]
    self.name    = "Paid Charges"
    self.save
  end

  def daily
    Charge.where(paid:false).collection.aggregate([project,groupby("day")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["day"]).days).to_i,data["count"]]
    end
  end

  def weekly
    Charge.where(paid:false).collection.aggregate([project,groupby("week")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["week"]).weeks).to_i, data["count"] ]
    end
  end

  def monthly
    Charge.where(paid:false).collection.aggregate([project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i, data["count"] ]
    end
  end

  private

  def project
    {"$project" => 
      {
        "charges" => 1,
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
