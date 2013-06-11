class ChargeImport < Import
  def get_from_stripe
    objects = Stripe::Charge.all({:count => self.limit, 
                                  :created => {:gte => self.end_at.to_i,:lt => self.start_at.to_i}},
                                  self.token)
    objects
  end

  def persiste!(charges)
    if self.mode == :from_stripe
      charges.data.each do |ch|
        record = ::Charge.where(stripe_id:ch.id).first
        user.charges << ::Charge.create(Charge.from_stripe(ch.as_json)) if record.nil? 
      end    
    else
      charges.each do |ch|
        record = ::Charge.where(stripe_id:ch['id']).first
        user.charges << ::Charge.create(Charge.from_stripe(ch)) if record.nil? 
      end    
    end
  end
end
