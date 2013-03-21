class DashboardController < ApplicationController
	def index
		@failedcharges = current_user.failed_charge_trend
    @paidcharges   = current_user.paid_charge_trend
	end
end
