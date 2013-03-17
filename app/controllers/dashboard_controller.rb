class DashboardController < ApplicationController
	def index
		@trend = current_user.acquisition_trend
	end
end
