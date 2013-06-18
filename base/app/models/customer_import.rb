class CustomerImport < Import
  def get_from_stripe
    objects = Stripe::Customer.all({:count => self.limit, 
                                  :created => {:gte => self.end_at.to_i,:lt => self.start_at.to_i}},
                                  self.token)
  end

  def persiste!(customers)
    if self.mode == :from_stripe
      user.stat.update_attribute(:stripe_customers,customers.count) if customers.count > user.stat.stripe_customers
      customers.data.each do |ch|
        record = ::Customer.where(stripe_id:ch.id).first
        user.customers << ::Customer.create(::Customer.from_stripe(ch.as_json)) if record.nil? 
      end    
    else
      customers.each do |ch|
        record = ::Customer.where(stripe_id:ch['id']).first
        user.customers << ::Customer.create(::Customer.from_stripe(ch)) if record.nil? 
      end    
    end
  end
end
