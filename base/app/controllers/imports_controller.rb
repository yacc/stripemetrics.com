class ImportsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @charge_import_director   = current_user.charge_import_director
    @customer_import_director = current_user.customer_import_director
    @sde_import_director      = current_user.sde_import_director
    @cde_import_director      = current_user.cde_import_director
  end

end