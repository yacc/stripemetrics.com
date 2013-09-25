class DashboardController < ApplicationController
  before_filter :authenticate_user!

	def index
    @paid_charges     = current_user.trends.where(type:'new_mrr').last
    @failed_charges   = current_user.trends.where(type:'failed_mrr').last
    @customers        = current_user.trends.where(type:'new_cust').last
    @cancelations     = current_user.trends.where(type:'churn_cust').last
  end

end
