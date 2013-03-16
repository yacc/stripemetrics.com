class Subscription
  include Mongoid::Document
  field :start, type: Date
  field :canceled_at, type: Date
  field :ended_at, type: Date
  field :status, type: String
  field :redflags, type: Array

  embedded_in :customers, :inverse_of => :subscription
  embeds_one  :plan
  accepts_nested_attributes_for :plan
end