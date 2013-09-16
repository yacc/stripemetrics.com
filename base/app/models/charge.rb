class Charge
  include Mongoid::Document
  field :stripe_id, type: String
  field :customer,  type: String
  field :created,   type: Date 
  field :livemode,  type: Boolean
  field :paid,      type: Boolean
  field :amount,    type: Integer
  field :currency,  type: String
  field :refunded,  type: Boolean
  field :fee,       type: Integer
  field :captured,  type: Boolean
  field :amount_refunded, type: Integer
  field :dispute,   type: Boolean
  field :new_mrr,   type: Boolean, default: false

  belongs_to :user 
  embeds_one :card

  index({ stripe_id: 1 }, { unique: true, background: true })

  def self.from_stripe(json_obj)
    json_obj.except!("fee_details")
    json_obj["card"] = ::Card.from_stripe(json_obj["card"])
    json_obj["stripe_id"] = json_obj["id"]
    json_obj.except!("id")    
  end

  def is_charge_from_new_customer?(customer_created_at)
    (customer_created_at.month == created.month) and (customer_created_at.year == created.year)
  end

end