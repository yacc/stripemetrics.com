class Customer
  include Mongoid::Document

  field :stripe_id,    type: String
  field :created,      type: Date
  field :canceled_at,  type: Date
  field :converted_at, type: Date

  embeds_one :subscription
  belongs_to :user

  def self.from_stripe(json_obj)
    json_obj["stripe_id"] = json_obj["id"]
    json_obj["subscription"].except!("plan") unless json_obj["subscription"].nil?
    json_obj.except("id")
  end
  
end
