module ChurnMrrAgregation
  extend ActiveSupport::Concern

  def aggregate_data
    monthly = {}
    self.data_source.collection.aggregate([match,project,groupby("month")]).collect do |data|
      monthly[(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i] = data["volume"]/100.0
    end
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
        "amount"  => "$subscription.plan.amount",
        "year"    => { "$year"  => "$canceled_at"}, 
        "month"   => { "$month" => "$canceled_at"}
      }
    }   
  end

  def groupby(interval)
      { "$group" =>
        { "_id" => {"year"=>"$year", "month"=>"$month"}, "volume" => { "$sum" => "$amount" } } 
      }
  end
	
end