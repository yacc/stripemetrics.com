module Stripe
  module Import
    class Customers

      def initialize(user_id,options={})
        @offset         = 0
        @count          = options[:count]  || 100
        @start_date     = options[:start_date] ?  Time.parse(options[:start_date]).to_i : 2.weeks.ago.to_i

        @cust_csv_filename = "customers_monthly_#{Time.now.strftime("%b_%Y")}.csv"
        @cust_csv_filepath = File.join('/tmp',"customers_monthly_#{Time.now.strftime("%b_%Y")}.csv")
        @cust_csv          = open(@cust_csv_filepath, 'w')

        @user           = User.find(user_id)
        @token          = @user.token
      end

      def run
        last_date = nil
        begin
          customers = Stripe::Customer.all({:count => @count, :offset => @offset},@token)
          last_date = process_customers(customers)
          @offset += @count
          print "-> #{last_date}\n"
        end while (last_date > @start_date) 
      end

      private

      def process_customers(customers)
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

      def update_subscription(record,cust)
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
            #todo: handle case where customer has many subscriptions
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
      end

    end
    
  end
end    