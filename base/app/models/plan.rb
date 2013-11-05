class Plan
  include Mongoid::Document
  field :interval, type: String
  field :amount, type: Integer
  embedded_in :subscriptions, :inverse_of => :plan

	def self.from_stripe(json_obj)
    return nil if json_obj.nil?		
    json_obj["stripe_id"] = json_obj["id"]    
    json_obj.except!("id")    
    json_obj
  end

end
