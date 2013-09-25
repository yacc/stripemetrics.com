class Metrics20Controller < ApplicationController
  before_filter :authenticate_user!

	def index
	  @mrrs   = current_user.trends.where(group:'mrr').where(dimension:nil)
	  @churns = current_user.trends.where(group:'churn').where(dimension:nil)
      @months = Trend.normalized_months(current_user)
  end

end
