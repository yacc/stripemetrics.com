class Customer
  include Mongoid::Document

  field :stripe_id,    type: String
  field :email,        type: String
  field :created,      type: Date
  field :canceled_at,  type: Date
  field :converted_at, type: Date
  field :ts_4_newmrr,  type: Date

  embeds_one :subscription
  belongs_to :user

  def self.from_stripe(json_obj)
    json_obj["subscription"] = ::Subscription.from_stripe(json_obj["subscription"])
    json_obj.except!("cards")    
    json_obj["stripe_id"] = json_obj["id"]
    json_obj.except!("id")
    json_obj["subscription"]["plan"] = ::Plan.from_stripe(json_obj["subscription"]["plan"])
    json_obj
  end
  
  def refresh_new_mrr_flag
    charges = (ts_4_newmrr.nil? ? Charge.where(customer:stripe_id) :
                                  Charge.where(customer:stripe_id).where(:created.gt => ts_4_newmrr)  ) 
    return if charges.empty?

    charges.each do |ch|
      ch.update_attribute(:new_mrr,true) if ch.is_charge_from_new_customer?(created)
    end
    self.ts_4_newmrr = charges.last.created
    self.save
  end

end
