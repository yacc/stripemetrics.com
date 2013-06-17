class CdeImport < Import
  def get_from_stripe
    events = Stripe::Event.all({:count => self.limit, 
                                :type => 'customer.deleted',
                                :created => {:gte => self.end_at.to_i,:lt => self.start_at.to_i}},
                                self.token)
  end

  def persiste!(events)
    if self.mode == :from_stripe
      user.stat.update_attribute(:stripe_cdes,events.count)
      events.data.each do |ev|
        cust_id = ev.data.object.id
        canceled_at = Time.at(ev.created)
        record = ::Customer.where(user_id:user._id).where(stripe_id:cust_id).first_or_create!
        record.update_attributes(canceled_at:canceled_at, created:Time.at(ev.data.object.created), subscription:{canceled_at:canceled_at})
      end
   else
      raise "Importing customer.deleted events from file is not supported yet"
    end
  end
end

#<Stripe::ListObject:0x81e713ec> JSON: {"object":"list","count":1,"url":"/v1/events","data":[{"id":"evt_1XDZXtDMlpg3QV","created":1364350661,"livemode":false,"type":"customer.deleted","data":{"object":{"id":"cus_1WTl23tpQroXTl","object":"customer","created":1364180256,"livemode":false,"description":"1 user-0047@sensr.net 995:usd:month:7 on test","email":"user-0047@sensr.net","subscription":{"plan":{"id":"995:usd:month:7","interval":"month","name":"Sensr Plan usd 995/month","amount":995,"currency":"usd","object":"plan","livemode":false,"interval_count":1,"trial_period_days":7,"identifier":"995:usd:month:7"},"object":"subscription","start":1364180256,"status":"trialing","customer":"cus_1WTl23tpQroXTl","current_period_start":1364180256,"current_period_end":1490410334,"trial_start":1364180256,"trial_end":1490410334,"quantity":1},"account_balance":0}},"object":"event","pending_webhooks":1,"request":null}]}