class TrendsController < ApplicationController
  before_filter :authenticate_user!

  def show
    type     = params[:type]
    group_by = params[:group_by]
    @trend   = current_user.send(type.underscore) 
    @data    = current_user.send(type.underscore).send(group_by)
    @unit    = find_trend_unit(type)

    respond_to do |format|
      format.html 
      format.json { render json: @data}
    end
  end

  private

  def find_trend_unit(type)
    case type
    when /Charge/
      '$'
    else
      ''
    end
  end

end


