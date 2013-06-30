class PlansController < ApplicationController
  before_filter :authenticate_user!, :only => :index_for_upgrading

  def index
  end

  def index_for_upgrading
  end    

end

