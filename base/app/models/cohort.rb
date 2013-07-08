class Cohort
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  field :matrix,    type: Array, :default => [] 
  belongs_to :user

  def refresh!
    monthly = cancellations
    cohort.matrix = []
    self.user.acquision_trend.refresh_monthly
    new_user = self.user.acquision_trend.montly
    i = j = 0
    self.user.cancellation_trend.monthly.each do |mo_i|
      # user acquisition month 'mo_i'
      self.user.cancellation_trend.monthly.each do |mo_j|
        if self.monthly[mo_i]
          cancellation_i_j = 0
        else  
          cancellation_i_j = (self.monthly[mo_i][mo_j].nil? ? 0 : self.monthly[mo_i][mo_j])
        end
        retention =  cancellation_i_j / mo_i[1] 
        cohort.matrix[i][j] = retention
        j += 1 
      end
      i += 1
    end    
    self.save
  end

  def cancellations
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

