class Metric
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,       type: String
  field :desc,       type: String
  field :this_month, type: Float
  field :last_month, type: Float
  field :change,     type: Float
  
  field :tsm_avrg,   type: Float
  field :goal,       type: Float
  field :unit,       type: String

  belongs_to :user

  attr_accessible :this_month, :last_month, :change, :tsm_avrg
  validates_inclusion_of :unit, in: [ 'count', 'dollars' ]

  def is_in_dollar?
    self.unit == 'dollars'
  end
end
