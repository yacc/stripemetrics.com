module NewMrrAgregation
  extend ActiveSupport::Concern

  def refresh_monthly
    self.data_source.collection.aggregate([match,project,groupby("month")]).collect do |data|
      [(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i*1000, data["volume"]/100.0 ]
    end.sort_by{|k|k[0]}
  end

  private

  def match
    {
      "$match" => { "paid" => true, "captured" => true, "user_id" => self.user_id, "new_mrr" => true}
    }
  end

  def project
    {"$project" => 
      {
        "amount"  => "$amount",
        "year"    => { "$year"  => "$created"}, 
        "month"   => { "$month" => "$created"}
      }
    }   
  end

  def groupby(interval)
      { "$group" =>
        { "_id" => {"year"=>"$year", "month"=>"$month"}, "volume" => { "$sum" => "$amount" } } 
      }
  end
	
end