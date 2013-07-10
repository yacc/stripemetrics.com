class CohortsController < ApplicationController
  before_filter :authenticate_user!

	def index
    @cohort   = current_user.cohort
  end

end
