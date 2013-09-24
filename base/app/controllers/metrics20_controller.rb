class Metrics20Controller < ApplicationController
  before_filter :authenticate_user!

	def index
	  @mrrs = [
              {metric:current_user.new_mrr_metric, trend:current_user.new_mrr_trend},
              {metric:current_user.churn_mrr_metric, trend:current_user.churn_mrr_trend}
            ]
    @months = @mrrs.last[:trend].monthly.collect{|mo| mo[0]}
  end

end
