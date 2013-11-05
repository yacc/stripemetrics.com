module Aggregatable
	extend ActiveSupport::Concern

  # included do
  #   validates_format_of :p_criteria, :with => /,$/, :message => 'Project criteria is not a valid json'
  #   validates_format_of :m_criteria, :with => /,$/, :message => 'Match criteria is not a valid json'
  # end

  def data_source
    @data_source ||= (self.user.send(source.to_sym)).collection 
  end

  def process!
    dimension.nil? ? process_by_month! : process_by_dimension! 
  end

  def process_by_month!
    monthly = {}
    logger.info "Aggregatable: aggragating #{source} user #{self.user_id} with \n * match:#{match}\n * project:#{project}\n * groupby:#{groupby}"
    data_source.aggregate([match,project,groupby]).collect do |data|
      monthly[(Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i] = data["total"]
    end
    self.update_attribute(:data,monthly)    
  end

  def process_by_dimension! 
    begin
      grouped_by_dim = {}
      logger.info "Aggregatable: aggragating #{source} user #{self.user_id} with \n * match:#{match}\n * project:#{project}\n * groupby:#{groupby}\n * dimension:#{dimension}"
      data_source.aggregate([match,project,groupby]).collect do |data|
        ts = (Time.new(data["_id"]["year"]) + (data["_id"]["month"]).month).to_i
        dim                 = data["_id"][dimension]
        grouped_by_dim[dim] ||= {}
        grouped_by_dim[dim][ts] = data["total"]
      end
      self.update_attribute(:data,grouped_by_dim)    
    rescue Exception => e
      logger.info "Aggregatable: failed aggragating #{source} user #{self.user_id}\n#{e}"
    end

  end

  def match
    hash = {}
    hash["$match"] = {"user_id" => Moped::BSON::ObjectId.from_string(self.user.id)}
    hash["$match"].merge!(m_criteria) unless m_criteria.empty?
    hash
  end

  def project
    hash = {}
    hash["$project"] = {"year"=>{"$year"=>"$#{groupby_ts}"}, "month"=>{"$month"=>"$#{groupby_ts}"} }
    hash["$project"].merge!(p_criteria) unless p_criteria.empty?
    hash
  end

  def groupby
    { "$group" =>
      { "_id"   => id_key, 
        "total" => total_fct
      } 
    }
  end

  def id_key
    case dimension
    when 'country'
      {"year"=>"$year", "month"=>"$month","country"=>"$country"}      
    when 'card_type'
      {"year"=>"$year", "month"=>"$month","card_type"=>"$card_type"}          
    when 'plan_type'
      {"year"=>"$year", "month"=>"$month","plan_type"=>"$plan_type"}          
    else
      {"year"=>"$year", "month"=>"$month"}      
    end
  end

  def total_fct
    case unit
    when 'amount'  
      { "$sum" => "$amount" } 
    else 'count'
      { "$sum" => 1 }
    end    
  end

end