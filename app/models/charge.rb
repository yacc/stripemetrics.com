class Charge
  include Mongoid::Document
  field :stripe_id, type: String
  field :created, type: Date 
  field :livemode, type: Boolean
  field :paid, type: Boolean
  field :amount, type: Integer
  field :currency, type: String
  field :refunded, type: Boolean
  field :fee, type: Integer
  field :captured, type: Boolean
  field :amount_refunded, type: Integer
  field :dispute, type: Boolean

  belongs_to :user

end