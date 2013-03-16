class JobsController < ApplicationController
	respond_to :json  

	def start
		Resque.enqueue(AggregateStripeCustomerData, current_user.id)
		render :json => :ok
	end

  
  # def error
  #   msg = { :code => 500, :message => "Sensr.net API version 2 (api2) is not supported anymore. Visit http://sensr.net/api for more information", :debug => '' }
  #   render :json => msg
  # end
  

end
