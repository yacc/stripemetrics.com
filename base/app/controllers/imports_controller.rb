class ImportsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @charge_imports     = current_user.charge_imports
    @customer_imports   = current_user.customer_imports
    @sde_imports        = current_user.sde_imports
    @cde_imports        = current_user.cde_imports
  end

end