require 'machinist/mongoid'

User.blueprint do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
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


