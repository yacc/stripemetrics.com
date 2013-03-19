class ChargeTrend
  include Mongoid::Document

  field :account,  type: String
  field :data,     type: Array
  field :start_at, type: Integer
  field :name,     type: String

  belongs_to :user
end
