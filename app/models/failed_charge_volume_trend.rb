class FailedChargeVolumeTrend < Trend

  def refresh!
    self.daily   = daily
    self.weekly  = weekly
    self.monthly = monthly
    self.start_date = self.daily[0][0] unless self.daily[0].nil?
    self.name    = "Failed Charges"
    self.save
  end

  def daily
    self.user.charges.where(paid:false).collection.aggregate([match,project,groupby("day")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["day"]).days).to_i*1000,data["volume"]/100.0]
    end.sort_by{|k|k[0]}
  end

  def weekly
    self.user.charges.where(paid:false).collection.aggregate([match,project,groupby("week")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["week"]).weeks).to_i*1000, data["volume"]/100.0 ]
    end.sort_by{|k|k[0]}
  end

  def monthly
    self.user.charges.where(paid:false).collection.aggregate([match,project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, data["volume"]/100.0 ]
    end.sort_by{|k|k[0]}
  end

  private

  def match
    {
      "$match" => { "paid" => false, "captured" => true}
    }
  end

  def project
    {"$project" => 
      {
        "amount" => "$amount",
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
        { "_id" => {"year"=>"$year", "day"=>"$day"}, "count" => { "$sum" => "$amount"}  } 
      }
    when "week"
      { "$group" =>
        { "_id" => {"year"=>"$year", "week"=>"$week"}, "count" => { "$sum" => "$amount"}  } 
      }
    when "month"      
      { "$group" =>
        { "_id" => {"year"=>"$year", "month"=>"$month"}, "count" => { "$sum" => "$amount"}  } 
      }
    end

  end
end
