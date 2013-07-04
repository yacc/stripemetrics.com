class CohortTable
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  field :monthly,    type: Array, :default => [] 
  belongs_to :user

  def refresh!
    self.montlhy = refresh_monthly
    self.save
  end

  def refresh_monthly
    Customer.collection.aggregate([match,project,groupby]).collect do |data|
      mo_created  = (Time.new(data["_id"]["year_created"]) + (data["_id"]["month_created"]).month).to_i*1000
      mo_canceled = (Time.new(data["_id"]["year_canceled"]) + (data["_id"]["month_canceled"]).month).to_i*1000
      [mo_created,mo_canceled,data["count"]]
    end
  end

  private

  def match
    { 
      "$match" => { "canceled_at" => { "$exists" => true },"user_id" => self.user_id  }
    }
  end

  def project
    {"$project" => 
      {
        "customers" => 1,
        "year_created"     => { "$year"  => "$created"}, 
        "month_created"    => { "$month" => "$created"},
        "year_canceled"    => { "$year"  => "$canceled_at"}, 
        "month_canceled"   => { "$month" => "$canceled_at"}
      }
    }   
  end

  def groupby
    { "$group" =>
      { "_id" => {"year_created"  =>"$year_created",   "month_created"  =>"$month_created",
                  "year_canceled"=>"$year_canceled", "month_canceled"=>"$month_canceled" 
                 }, 
        "count" => { "$sum" => 1 } 
      } 
    }    
  end
end

