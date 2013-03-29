class DashboardController < ApplicationController
	def index
		@failedcharges      = current_user.failed_charge_count_trend
    @paidcharges        = current_user.paid_charge_count_trend

    @paidchargesvol     = current_user.paid_charge_volume_trend
    @failedchargesvol   = current_user.failed_charge_volume_trend
    
    @customers          = current_user.acquisition_trend

    @ch_count     = [{:name=>@failedcharges.name,:data=>@failedcharges.daily},
                     {:name=>@paidcharges.name,:data=>@paidcharges.daily}].to_json
    @count_start  = @paidcharges.start_date || @failedcharges.start_date

    @ch_vol    = [{:name=>@failedchargesvol.name,:data=>@failedchargesvol.daily},
                  {:name=>@paidchargesvol.name,:data=>@paidchargesvol.daily}].to_json

    @vol_start = @paidchargesvol.start_date || @failedchargesvol.start_date

	end
end
