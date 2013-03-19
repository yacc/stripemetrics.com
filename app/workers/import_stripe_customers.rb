class ImportStripeCustomers
	@queue = :aggregation_queue

	def self.perform(user_id,options = {})
    offset         = 0
    count          = options[:count]  || 100
    start_date     = options[:start_date] ?  Time.parse(options[:start_date]).to_i : 2.weeks.ago.to_i
    user           = User.find(user_id)
    token          = @user.token

    last_date = nil
    begin
      customers = Stripe::Customer.all({:count => count, :offset => offset},token)
      last_date = process_customers(customers)
      offset += count
      print "-> #{last_date}\n"
    end while (last_date > start_date) 
  end

  private 
  def self.process_customers(customers)
    customers.data.each do |cust|
      custid  = cust.id
      created = cust.created 
      record = @user.customers.find_or_create_by(stripe_id: custid)
      record.created_at =  created
      record.save
      update_subscription(record,cust)
      print "."
    end
    last_date = customers.data.last.created
  end

  def self.update_subscription(record,cust)
    redflags = []
    if cust.respond_to? :subscription 
      if cust.subscription.nil?
        redflags << 'missing subscription'
      else
        status       = cust.subscription["status"]
        start        = cust.subscription["start"]
        canceled_at  = cust.subscription["canceled_at"]
        ended_at     = cust.subscription["ended_at"]
        interval     = cust.subscription.plan["interval"]
        amount       = cust.subscription.plan["amount"]
      end
    end
    if subs = record.subscription
      subs.update_attributes(status: status,canceled_at: canceled_at, ended_at: ended_at, 
       plan: {interval: interval, amount: amount},
       redflags: redflags )
    else
      record.create_subscription(start: start, canceled_at: canceled_at, ended_at: ended_at, status: status,
       plan: {interval: interval, amount: amount},
       redflags: redflags)
    end
  end

end  


