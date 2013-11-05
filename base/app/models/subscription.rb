class Subscription
  include Mongoid::Document

  field :start, type: Date
  field :canceled_at, type: Date
  field :ended_at, type: Date
  field :status, type: String

  embedded_in :customer
  embeds_one  :plan
  accepts_nested_attributes_for :plan

  def self.from_stripe(json_obj)
    return nil if json_obj.nil?
  	json_obj.except!("customer","object")
    json_obj["stripe_id"] = json_obj["id"]    
    json_obj.except!("id")
    json_obj    
  end

end

