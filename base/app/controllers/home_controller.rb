class HomeController < ApplicationController

  def index
    redirect_to :dashboard if user_signed_in? 
  end

	def quickstart
    redirect_to :dashboard if user_signed_in? 
	end

  def faq
  end

  def pricing
  end

end
