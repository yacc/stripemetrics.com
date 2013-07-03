class CohortTable
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  field :monthly,    type: Array, :default => [] 
  belongs_to :user

  def refresh!
    self.monthly = refresh_monthly
    self.save
  end

  def refresh_monthly
    Customer.collection.aggregate([match,project,groupby]).collect do |data|
      mo_created  = (Time.new(data["_id"]["year_created"]) + (data["_id"]["month_created"]).month).to_i*1000
      mo_canceled = (Time.new(data["_id"]["year_cancelled"]) + (data["_id"]["month_cancelled"]).month).to_i*1000
      [mo_created,mo_canceled,data["count"]]
    end.sort_by{|k|k[0]}
  end

  private

  def match
    { 
      "$match" => {"cancelled_at" => {"$ne" => "null"},"user_id" => self.user_id  }
    }
  end

  def project
    {"$project" => 
      {
        "customers" => 1,
        "year_created"     => { "$year"  => "$created"}, 
        "month_created"    => { "$month" => "$created"},
        "year_cancelled"    => { "$year"  => "$cancelled_at"}, 
        "month_cancelled"   => { "$month" => "$cancelled_at"}
      }
    }   
  end

  def groupby
    { "$group" =>
      { "_id" => {"year_created"  =>"$year_created",   "month_created"  =>"$month_created",
                  "year_cancelled"=>"$year_cancelled", "month_cancelled"=>"$month_cancelled" 
                 }, 
        "count" => { "$sum" => 1 } 
      } 
    }    
  end
end

