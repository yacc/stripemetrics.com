class Metrics20Controller < ApplicationController
  before_filter :authenticate_user!

	def index
		# MRR
	  @mrrs        = current_user.trends.where(group:'mrr').where(dimension:nil)
	  @net_new_mrr = new_mrr - failed_mrr - churn_mrr

	  # CHURN
	  @churns      = current_user.trends.where(group:'churn').where(dimension:nil)
	  @net_new_customers = new_cust - churn_cust 
	  @total_customers = new_cust.total

    @months = Trend.normalized_months(current_user)
  end


  private

  def new_mrr
  	current_user.trends.where(type:'new_mrr').first
  end

  def failed_mrr
		current_user.trends.where(type:'failed_mrr').first
  end

  def churn_mrr
  	current_user.trends.where(type:'churn_mrr').first
  end

  def new_cust
		current_user.trends.where(type:'new_cust').first
  end

  def churn_cust  	
		current_user.trends.where(type:'churn_cust').first
  end
end
