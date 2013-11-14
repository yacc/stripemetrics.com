class TrendsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @trend   = current_user.trends
    @trend   = @trend.where(type:params[:type]) if params[:type] 
    @trend   = @trend.where(type:params[:dimension]) if params[:dimension] 
    @trend   = @trend.last
    
    respond_to do |format|
      format.html 
      format.json { render json: @data}
    end
  end

  def aggregate
    type     = params[:type]
    group_by = params[:group_by]
    group_by_countries = params[:group_by_countries]

    @trend   = current_user.send(type.underscore) 
    @data    = current_user.send(type.underscore).group_by_month_and_by_countries

    respond_to do |format|
      format.json { render json: @data}
    end
  end
  
  def index
    # MRR
    @lost        = current_user.trends.where(group:'lost')
    @mrrs        = current_user.trends.where(group:'mrr').where(dimension:nil)
    @net_new_mrr = new_mrr - churn_mrr

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


