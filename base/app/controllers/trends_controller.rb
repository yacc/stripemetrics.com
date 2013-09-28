class TrendsController < ApplicationController
  before_filter :authenticate_user!

  def show
    type      = 
    dimension = 
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

end


