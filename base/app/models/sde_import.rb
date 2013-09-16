class SdeImport < Import
  def get_from_stripe
    events = Stripe::Event.all({:count => self.limit, 
                                :type => 'customer.subscription.deleted',
                                :created => {:gte => self.end_at.to_i,:lt => self.start_at.to_i}},
                                self.token)
  end

  def persiste!(events)
    if self.mode == :from_stripe
      user.stat.update_attribute(:stripe_sdes,events.count) if events.count > user.stat.stripe_sdes
      events.data.each do |ev|
        cust_id = ev.data.object.customer
        canceled_at = Time.at(ev.created)
        record = ::Customer.where(user_id:user._id).where(stripe_id:cust_id).first_or_create!
        record.update_attributes(canceled_at:canceled_at, created:Time.at(ev.data.object.start), subscription:{canceled_at:canceled_at})
      end
    else
      raise "Importing customer.subscription.deleted events from file is not supported yet"
    end
  end
end

