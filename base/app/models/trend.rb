class Trend
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  field :name,     type: String
  field :interval, type: String
  field :start_date, type: Integer

  field :daily,      type: Array, :default => []
  field :daily_no_ts,type: Array, :default => []
  field :weekly,     type: Array, :default => []
  field :monthly,    type: Array, :default => []
  belongs_to :user

end
