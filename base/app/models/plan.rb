class Plan
  include Mongoid::Document
  field :interval, type: String
  field :amount, type: Integer
  embedded_in :subscriptions, :inverse_of => :plan
end
