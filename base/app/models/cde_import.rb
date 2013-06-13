class CdeImport < Import
  def get_from_stripe
    events = Stripe::Event.all({:count => self.limit, 
                                :type => 'customer.deleted',
                                :created => {:gte => self.end_at.to_i,:lt => self.start_at.to_i}},
                                self.token)
  end

  def persiste!(events)
    if self.mode == :from_stripe
      events.data.each do |ev|
        cust_id = ev.data.object.id
        document = {canceled_at:ev.created, created:ev.data.object.created, subscription:{canceled_at:ev.created}}
        customer = ::Customer.where(stripe_id:cust_id).find_and_modify({ "$set" => document}, { upsert:true,new:true })
        user.customers << customer unless customer.nil?    
      end
   else
      raise "Importing customer.deleted events from file is not supported yet"
    end
  end
end
