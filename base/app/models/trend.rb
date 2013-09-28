class Trend
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short
  include Aggregatable

  field :name,       type: String
  field :group,      type: String
  field :interval,   type: String
  field :start_date, type: Integer
  field :unit,       type: String
  field :type,       type: String
  field :desc,       type: String
  field :source,     type: String
  field :p_criteria, type: Hash
  field :m_criteria, type: Hash
  field :groupby_ts, type: String
  field :dimension,  type: String
  field :data,       type: Hash, :default => {}

  belongs_to :user

  def self.normalized_months(user)
    trend_id = user.trends.where(dimension:nil).collect{|t| [t.data.size,t._id]}.max[1]
    trend = Trend.find(trend_id)
    trend.data.keys.sort
  end

  # ---- OPERATOR ON TREND ----
  def -(trend)
    result = Trend.new(user_id:self.user.id,name:"#{self.name}-#{trend.name}",group:self.group,unit:self.unit)
    months = self.data.keys + trend.data.keys        
    months.each do |mo|
      result.data[mo] = (self.data[mo].nil? ? 0 : self.data[mo]) - (trend.data[mo].nil? ? 0 : trend.data[mo])
    end
    result
  end

  def +(trend)
    result = Trend.new(user_id:self.user.id,name:"#{self.name}-#{trend.name}",group:self.group,unit:self.unit)
    months = self.data.keys + trend.data.keys        
    months.each do |mo|
      result.data[mo] = (self.data[mo].nil? ? 0 : self.data[mo]) + (trend.data[mo].nil? ? 0 : trend.data[mo])
    end
    result    
  end

  def total
    result = Trend.new(user_id:self.user.id,name:"total_#{self.source}",group:self.group,unit:self.unit)
    Trend.normalized_months(self.user).each do |mo|
      result.data[mo]= self.user.send(source.to_sym).where(:created.lt => mo.to_i).count
    end
    result
  end

  def as_highchart_data
    self.data.collect{|k,v| [k.to_i*1000,v]}.sort
  end

end
