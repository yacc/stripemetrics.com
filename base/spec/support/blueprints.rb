require 'machinist/mongoid'

User.blueprint do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
  revenue_metric
end

RevenueMetric.blueprint do
  name{"Monthly Revenue"} 
  desc{"Monthly Revenue (successfull charges)"} 
  this_month{100}
  last_month{50}
  change{100}
  tsm_avrg{7}
end

SdeImport.blueprint do
  status {"processing"}
  time {1.hour}
  count {450}   
end

Import.blueprint do
  type {"ChargeImport"}
  status {"processing"}
  time {1.hour}
  count {450}   
end

Charge.blueprint do
  # Attributes here
end

Trend.blueprint do
  # Attributes here
end

Account.blueprint do
  # Attributes here
end


