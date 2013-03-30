class FailedChargeVolumeTrend < Trend

  def refresh!
    refresh_daily
    refresh_weekly
    refresh_monthly
    self.start_date = self.daily[0][0] unless self.daily[0].nil?
    self.name    = "Failed Charges"
    self.save
  end

  def refresh_daily
    self.user.charges.collection.aggregate([match,project,groupby("day")]).collect do |data|
      vol_usd = data["volume"]/100.0 if data["volume"]
      [(Time.new(data["_id"]["year"]) + (data["_id"]["day"]).days).to_i*1000, vol_usd ]
    end.sort_by{|k|k[0]}
  end

  def refresh_weekly
    self.user.charges.collection.aggregate([match,project,groupby("week")]).collect do |data|
      vol_usd = data["volume"]/100.0 if data["volume"]
      [(Time.new(data["_id"]["year"]) + (data["_id"]["week"]).weeks).to_i*1000, vol_usd]
    end.sort_by{|k|k[0]}
  end

  def refresh_monthly
    self.user.charges.collection.aggregate([match,project,groupby("month")]).collect do |data|
      vol_usd = data["volume"]/100.0 if data["volume"]
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, vol_usd ]
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
