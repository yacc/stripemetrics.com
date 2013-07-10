class MetricsController < ApplicationController
  before_filter :authenticate_user!

	def index
    @metrics = [current_user.revenue_metric, current_user.lost_revenue_metric,
                 current_user.acquisition_metric,current_user.cancellation_metric]             
  end

end
