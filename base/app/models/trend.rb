class Trend
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  field :name,     type: String
  field :interval, type: String
  field :start_date, type: Integer

  field :daily,      type: Array
  field :daily_no_ts,type: Array
  field :weekly,     type: Array
  field :monthly,    type: Array
  belongs_to :user

end
