class TrendsController < ApplicationController
  before_filter :authenticate_user!

  def show
    type     = params[:type]
    group_by = params[:group_by]
    @trend   = current_user.send(type.underscore) 
    @data    = current_user.send(type.underscore).send(group_by)

    respond_to do |format|
      format.html 
      format.json { render json: @data}
    end
  end

end


