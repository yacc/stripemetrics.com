module Metrics20Helper
	def mmr_date(mo)
    Time.at(mo.to_i).strftime("%b %Y")    
  end
end

