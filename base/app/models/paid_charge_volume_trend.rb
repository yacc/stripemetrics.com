class PaidChargeVolumeTrend < Trend

  def refresh!
    self.daily   = refresh_daily
    self.weekly  = refresh_weekly
    self.monthly = refresh_monthly
    self.start_date = self.daily[0][0] unless self.daily.nil? || self.daily[0].nil?
    self.name    = "Paid Charges Volume"
    self.unit    = "dollars"
    self.save
  end

  def refresh_daily
    self.user.charges.collection.aggregate([match,project,groupby("day")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["day"]).days).to_i*1000,data["volume"]/100.0]
    end.sort_by{|k|k[0]}
  end


  def refresh_weekly
    self.user.charges.collection.aggregate([match,project,groupby("week")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["week"]).weeks).to_i*1000, data["volume"]/100.0 ]
    end.sort_by{|k|k[0]}
  end

  def refresh_monthly
    self.user.charges.collection.aggregate([match,project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, data["volume"]/100.0 ]
    end.sort_by{|k|k[0]}
  end

  def group_by_month_and_by_countries
    volume = {}
    xaxis     = []
    countries = []
    self.user.charges.collection.aggregate([match,project,groupby("month")]).each do |data|
      ts      = (Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000
      country = data["_id"]["country"]
      volume[country] ||= {}
      volume[country][ts] = data["volume"]/100.0
      countries << country
      xaxis << ts
    end
    countries.uniq!
    xaxis.uniq!.sort!
    series = []
    countries.each do |country|
      entry = {'name'=>country,'data'=>[]}
      xaxis.each do |mo|
        entry['data'] << [mo,((volume[country][mo]).nil? ? 0 : volume[country][mo])]
      end
      series << entry
    end
    series
  end

  private

  def match
    {
      "$match" => { "paid" => true, "captured" => true, "user_id" => self.user_id}
    }
  end

  def project
    {"$project" => 
      {
        "amount"  => "$amount",
        "country" => "$card.country" ,
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
        { "_id" => {"year"=>"$year", "day"=>"$day"}, "volume" => { "$sum" => "$amount"} } 
      }
    when "week"
      { "$group" =>
        { "_id" => {"year"=>"$year", "week"=>"$week"}, "volume" => { "$sum" => "$amount" } } 
      }
    when "month"      
      { "$group" =>
        { "_id" => {"year"=>"$year", "month"=>"$month","country"=>"$country"}, "volume" => { "$sum" => "$amount" } } 
      }
    end

  end
end
