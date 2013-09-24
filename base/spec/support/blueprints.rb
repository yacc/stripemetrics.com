require 'machinist/mongoid'

User.blueprint(:basic) do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
end

User.blueprint do
  email {"yacin@stripemetrics.com"}
  livemode {"false"}
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

Customer.blueprint do 
  user
  stripe_id {"customer_id_#{sn}"}
  email{"cheap_yyy@uuu..ooo"}
  created{ Time.now } 
  canceled_at{ Time.now + 3.month }
  converted_at{ Time.now + 6.days }  
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
  amount_refunded{0}
  dispute{false}
  new_mrr{false}
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
  type {"new_mrr"}
  group {"mrr"}
  name {"New MRR"}
  desc {"Monthly recuring revenue from new customers"}
  unit {"amount"}
  source {"charges"}
  interval {"month"}
  p_criteria { {"amount"=>"$amount"} }
  m_criteria { {} }
  groupby_ts {%Q|created|}
end

Trend.blueprint(:new_mrr) do
  type {"new_mrr"}
  group {"mrr"}
  name {"New MRR"}
  desc {"Monthly recuring revenue from new customers"}
  unit {"amount"}
  source {"charges"}
  interval {"month"}
  p_criteria { {"amount"=>"$amount"} }
  m_criteria { {"paid"=>true,"captured"=>true,"new_mrr"=>true} }
  groupby_ts {%Q|created|}
end

Account.blueprint do
  # Attributes here
end


