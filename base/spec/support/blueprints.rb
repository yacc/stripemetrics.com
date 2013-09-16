require 'machinist/mongoid'

User.blueprint(:basic) do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
end

User.blueprint do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
  revenue_metric
end

User.blueprint(:with_charges) do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
end

Customer.blueprint do  
  user
  stripe_id {"customer_id_#{sn}"}
  email{"yyy@uuu..ooo"}
  created{ Time.now } 
  canceled_at{ Time.now + 4.month }
  converted_at{ Time.now + 6.days }
  #charges{ [{created:object.created},{created:(object.created+1.month)},{created:(object.created+2.month)}] }
end

Customer.blueprint(:no_charges) do 
  user
  stripe_id {"customer_id_#{sn}"}
  email{"cheap_yyy@uuu..ooo"}
  created{ Time.now } 
  canceled_at{ Time.now + 3.month }
  converter_at{ Time.now + 6.days }  
end

Charge.blueprint do
  stripe_id {"charge_id_#{sn}"}
  customer {"customer_id_#{sn}"}
  created {Time.now}   
  livemode {false}
  paid {true}     
  amount{"4500"}   
  currency{"usd"} 
  refunded{false}
  fee{145}
  captured{true} 
  dispute{false}
end


RevenueMetric.blueprint do
  name{"Monthly Revenue"} 
  desc{"Monthly Revenue (successfull charges)"} 
  this_month{100}
  last_month{50}
  change{100}
  tsm_avrg{7}
  unit{"dollars"}
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


Trend.blueprint do
  # Attributes here
end

Account.blueprint do
  # Attributes here
end


