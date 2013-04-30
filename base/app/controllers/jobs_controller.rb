class JobsController < ApplicationController
  before_filter :authenticate_user!
	respond_to :json

	def index
		
	end

	def start
		jobtype = params[:job_type]
		options = {start_date: params[:start_date],end_date: params[:end_date]}
		if jobtype == "import_customers"
			Resque.enqueue(ImportStripeCustomers, current_user.id,options)
			render :json => :ok
		elsif jobtype == "import_charges"
			Resque.enqueue(ImportStripeCharges, current_user.id,options)
			render :json => :ok
		elsif jobtype == "customer_acquisition_trend"
			Resque.enqueue(CustomerAcquisitionTrend, current_user.id,options)
			render :json => :ok
		elsif jobtype == "charge_trend"
			Resque.enqueue(UpdateChargeTrend, current_user.id,options)
			render :json => :ok
		else
			render :json => :ok
		end
	end

end


