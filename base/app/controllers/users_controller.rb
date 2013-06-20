class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
  end
  
  def update
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
    @user.email = params[:user][:email] if params[:user][:email]
    @user.password = params[:user][:password] if params[:user][:password]

    if @user.save
      flash[:success] = "You successfully updated your account!" 
    end
    render :edit
  end

  def destroy
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
    @user.destroy
    redirect_to :root
  end

end
