class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @max_data_points = 12
    @mrr          = current_user.trends.where(type:'mrr').first
    @new_mrr      = current_user.trends.where(type:'new_mrr').first
    @failed_mrr   = current_user.trends.where(type:'failed_mrr').first
    @new_cust     = current_user.trends.where(type:'new_cust').first
    @churn_cust   = current_user.trends.where(type:'churn_cust').first

    @charge_imports     = current_user.charge_imports
    @customer_imports   = current_user.customer_imports
    @sde_imports        = current_user.sde_imports
    @cde_imports        = current_user.cde_imports

  end

end
