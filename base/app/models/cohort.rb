class Cohort
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  field :matrix,       type: Array, :default => [] 
  field :joined_in,    type: Array, :default => [] 

  belongs_to :user

  def refresh!
    self.matrix = []
    self.user.acquisition_trend.refresh!
    new_users = self.user.acquisition_trend.monthly
    self.joined_in = self.user.acquisition_trend.monthly.map{|m| m[0]}
    nb_month = new_users.size - 1
    new_users.each_with_index do |mo_i,i|
      self.matrix[i]   = []
      cancellation_i_j = 0
      j = 0
      new_users.each do |mo_j|
        break if j > nb_month-i
        cancellation_i_j += cancellations_for_month(mo_i,mo_j)
        retention_i_j =  1.0 - cancellation_i_j.to_f / mo_i[1].to_f 
        self.matrix[i][j] = retention_i_j
        j += 1 
      end
    end    
    self.save
  end

  def cancellations
    sparse_matrix = {}
    Customer.collection.aggregate([match,project,groupby]).collect do |data|
      mo_created  = (Time.new(data["_id"]["year_created"]) + (data["_id"]["month_created"]).month).to_i*1000
      mo_canceled = (Time.new(data["_id"]["year_canceled"]) + (data["_id"]["month_canceled"]).month).to_i*1000
      sparse_matrix[mo_created] ||= {}
      sparse_matrix[mo_created][mo_canceled] = data["count"]
    end
    sparse_matrix
  end

  private

  def cancellations_for_month(mo_i,mo_j)
    monthly_cancellations = cancellations
    if monthly_cancellations[mo_i[0]].nil? 
      cancellation_i_j = 0.0
    elsif monthly_cancellations[mo_i[0]] && monthly_cancellations[mo_i[0]][mo_j[0]].nil?
      cancellation_i_j = 0.0
    else  
      cancellation_i_j = monthly_cancellations[mo_i[0]][mo_j[0]]
    end
  end

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

