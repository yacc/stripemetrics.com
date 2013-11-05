class Card
  include Mongoid::Document
  field :stripe_id, type: String
  field :card_type, type: String
  field :exp_month, type: Integer
  field :exp_year,  type: Integer
  field :country,   type: String
  field :customer,  type: String

  embedded_in :charge

  def self.from_stripe(json_obj)
    json_obj.except!("object","customer","fingerprint",)
    json_obj["card_type"] = json_obj["type"]
    json_obj.except!("type")    
    json_obj["stripe_id"] = json_obj["id"]
    json_obj.except!("id")    
    json_obj
  end

end
