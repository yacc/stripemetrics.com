module Metrics20Helper

	def mmr_date(mo)
    Time.at(mo.to_i).strftime("%b %Y")    
  end

  def human_data(trend,month)
    nbr = trend.data[month].nil? ? 0 : trend.data[month]
    case trend.unit
    when 'amount'
      number_to_currency(nbr/100, :unit => "$")
    else 'count'
      nbr
    end

  end
end

