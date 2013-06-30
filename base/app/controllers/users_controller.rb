class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
  end
  
  def update
    # authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    params[:user] = params[:user].except(:role_ids)
    if @user.update_attributes(params[:user])
      @user.update_plan(role) unless role.nil?
      redirect_to account_path, :notice => "You successfully updated your account!"
    else
      redirect_to account_path, :alert => "Ops ... we couldn\'t update your account!\n #{current_user.errors.join}"
    end
  end

  def upgrade_from_trial
    plan_status = current_user.update_plan(params[:plan]) if params[:plan].present?
    current_user.stripe_token = params[:stripe_token]
    if plan_status && current_user.save
      redirect_to account_path, :notice => "You successfully updated your account!"
    else
      redirect_to upgrading_path, :alert => "Ops ... we couldn\'t update your account!\n #{current_user.errors.join}"
    end
  end

  def destroy
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
    @user.destroy
    redirect_to :root
  end

end
