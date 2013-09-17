module ChargeVolumeAggregation
  extend ActiveSupport::Concern

  def refresh_monthly
    self.data_source.collection.aggregate([match,project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, [data["_id"]["country"],data["volume"]/100.0] ]
    end.sort_by{|k|k[0]}
  end

  def group_by_month_and_by_countries
    volume = {}
    xaxis     = []
    countries = []
    self.data_source.collection.aggregate([match,project,groupby("month")]).each do |data|
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
        entry['data'] << ((volume[country][mo]).nil? ? 0 : volume[country][mo])
      end
      series << entry
    end
    [series,xaxis]
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
        "year"    => { "$year"  => "$created"}, 
        "month"   => { "$month" => "$created"},
        "week"    => { "$week"  => "$created"}, 
        "day"     => { "$dayOfYear" => "$created"}, 
        "country" => "$card.country" 
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