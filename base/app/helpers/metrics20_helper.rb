module Metrics20Helper
	def mmr_date(mo)
    Time.at(mo/1000).strftime("%b %Y")    
  end
end

