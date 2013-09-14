class Metrics20Controller < ApplicationController
  before_filter :authenticate_user!

	def index
	  @new_mrrs = [
                  {metric:current_user.new_mrr_metric, trend:current_user.new_mrr_trend}
                ]
    @months   = @new_mrrs.first[:trend].monthly.collect{|mo| mo[0]}
  end

end
