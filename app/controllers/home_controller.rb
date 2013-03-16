class HomeController < ApplicationController
	#layout "dashboard"

	def index
		@trend = current_user.acquisition_trend
	end
end
