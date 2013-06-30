class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
  end
  
  def update
    plan = params[:user][:plan] unless params[:user][:plan].nil?
    params[:user] = params[:user].except(:plan)
    if current_user.update_attributes(params[:user])
      current_user.update_plan(plan) unless plan.nil?
      redirect_to account_path, :notice => "You successfully updated your account!"
    else
      redirect_to account_path, :alert => "Ops ... we couldn\'t update your account!\n #{current_user.errors.full_messages.join}"
    end
  end

  def upgrade_from_trial
    plan_status = current_user.update_plan(params[:plan]) if params[:plan].present?
    current_user.stripe_token = params[:stripe_token]
    if plan_status && current_user.save
      redirect_to account_path, :notice => "You successfully updated your account!"
    else
      redirect_to upgrading_path, :alert => "Ops ... we couldn\'t update your account!\n #{current_user.errors.full_messages.join}"
    end
  end

  def update_plan
    plan = params[:user][:plan] unless params[:user][:plan].nil?
    if current_user.update_plan(plan)
      redirect_to account_path, :notice => 'Updated plan.'
    else
      flash.alert = 'Unable to update plan.'
      render account_path
    end
  end

  def destroy
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
    @user.destroy
    redirect_to :root
  end

end
