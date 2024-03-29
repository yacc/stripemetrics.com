class SessionsController < ApplicationController

  def new
    redirect_to '/auth/stripe_connect'
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'], :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    raise "Session error: failed to create a user #{user.errors}" if user.nil?
    
    session[:user_id] = user.id
    if user.email.blank?
      redirect_to account_path, :error => "Please enter your email address."
    else
      redirect_to root_url, :notice => 'Signed in!'
    end

  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
