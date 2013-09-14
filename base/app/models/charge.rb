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
  field :new_mmr,   type: Boolean, default: false

  before_save :set_new_mrr_flag if :is_charge_from_new_customer?

  belongs_to :user 

  def self.from_stripe(json_obj)
    json_obj.except!("card","fee_details")
  end

  def set_new_mrr_flag
    self.new_mmr = true 
  end

  def is_charge_from_new_customer?
    cst = Customer.where(stripe_id:customer).first  
    !cst.nil? and (cst.created.month == created.month) and (cst.created.year == created.year)
  end

end