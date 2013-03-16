class Customer
  include Mongoid::Document

  field :stripe_id, type: String
  field :created_at, type: Date
  field :canceled_at, type: Date
  field :converted_at, type: Date

  embeds_one :subscription
  belongs_to :user
end
