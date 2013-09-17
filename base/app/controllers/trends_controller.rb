class TrendsController < ApplicationController
  before_filter :authenticate_user!

  def show
    type     = params[:type]
    group_by = params[:group_by]
    @trend   = current_user.send(type.underscore) 
    @data    = current_user.send(type.underscore).send(group_by)

    @series  = current_user.send(type.underscore).group_by_month_and_by_countries

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


