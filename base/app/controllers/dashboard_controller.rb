class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @new_mrr      = current_user.trends.where(type:'new_mrr').first
    @failed_mrr   = current_user.trends.where(type:'failed_mrr').first
    @new_cust     = current_user.trends.where(type:'new_cust').first
    @churn_cust   = current_user.trends.where(type:'churn_cust').first
  end

end
