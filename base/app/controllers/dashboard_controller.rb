class DashboardController < ApplicationController
  before_filter :authenticate_user!

	def index
    @paid_charges     = current_user.paid_charge_volume_trend
    @failed_charges   = current_user.failed_charge_volume_trend
    @customers        = current_user.acquisition_trend
    @cancelations     = current_user.cancellation_trend
  end

end
