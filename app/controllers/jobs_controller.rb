class JobsController < ApplicationController
  	before_filter :authenticate_user!
	respond_to :json

	def index
		
	end

	def start
		jobtype = params[:job_type]
		if jobtype == "aggregate_stripe_customer_data"
			Resque.enqueue(AggregateStripeCustomerData, current_user.id,params[:start_date],params[:end_date])
			render :json => :ok
		elsif jobtype == "customer_acquisition_trend"
			Resque.enqueue(CustomerAcquisitionTrend, current_user.id,params[:start_date],params[:end_date])
			render :json => :ok
		else
			render :json => :ok
		end
	end

end
