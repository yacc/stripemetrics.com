class Metric
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,       type: String
  field :desc,       type: String
  field :this_month, type: Float
  field :last_month, type: Float
  field :this_month_ts, type: String
  field :last_month_ts, type: String
  field :change,     type: Float
  
  field :tsm_avrg,   type: Float
  field :goal,       type: Float
  field :unit,       type: String

  belongs_to :user

  attr_accessible :this_month, :last_month, :change, :tsm_avrg
  validates_inclusion_of :unit, in: [ 'count', 'dollars' ]

  LAST_MONTH_INDEX = -3
  THIS_MONTH_INDEX = -2

  def is_in_dollar?
    self.unit == 'dollars'
  end

  def refresh!
    return if data.size < 3
    self.reset!
    self.last_month = data[LAST_MONTH_INDEX][1]
    self.this_month = data[THIS_MONTH_INDEX][1]
    self.last_month_ts = Time.at(data[LAST_MONTH_INDEX][0]/1000).strftime("%Y-%m-%d")
    self.this_month_ts = Time.at(data[THIS_MONTH_INDEX][0]/1000).strftime("%Y-%m-%d")
    historical_data_size = data.size

    if historical_data_size >= 6
      last_six_month_data = data[-6..-1]
      self.change     = relative_change(last_six_month_data)
      self.tsm_avrg   = tsm_average(last_six_month_data)
    end

    setup_description      
    self.save
  end

  def reset!
    self.this_month = nil
    self.last_month = nil
    self.this_month_ts = nil
    self.last_month_ts = nil
    self.change     = nil
    self.tsm_avrg   = nil      
  end

  def relative_change(data)
    this_month = data[THIS_MONTH_INDEX][1].to_f
    last_month = data[LAST_MONTH_INDEX][1].to_f
    change = (this_month - last_month)
    (change / this_month)
  end


  def tsm_average(data)
    num_periods    = data.size.to_f
    starting_value = data.first[1].to_f  
    ending_value   = data.last[1].to_f  
    ((ending_value/starting_value)**(1./num_periods))-1
  end

end
