class TrendsController < ApplicationController
  before_filter :authenticate_user!
	respond_to :json

	def index
		type     = params[:type]
		group_by = params[:group_by]
		trend    = current_user.send(type).send(group_by) 
    render json: trend
	end

end


