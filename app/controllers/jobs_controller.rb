class JobsController < ApplicationController
	respond_to :json  

	def start
		jobtype = params[:type]
		if jobtype == "aggregate_stripe_customer_data"
			Resque.enqueue(AggregateStripeCustomerData, current_user.id)
			render :json => :ok
		elsif jobtype == "customer_acquisition_trend"
			Resque.enqueue(CustomerAcquisitionTrend, current_user.id)
			render :json => :ok
		else
			render :json => :ok
		end
	end

  
  # def error
  #   msg = { :code => 500, :message => "Sensr.net API version 2 (api2) is not supported anymore. Visit http://sensr.net/api for more information", :debug => '' }
  #   render :json => msg
  # end
  

end
