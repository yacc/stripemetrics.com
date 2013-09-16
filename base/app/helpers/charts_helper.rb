module ChartsHelper

  def formated_axis_label(trend)
    case trend.unit
    when 'dollars'
      %Q{'$' + ((this.value>1000) ? (this.value/1000 +'k') : (this.value))}
    else 'count'
      %Q{'$' + ((this.value>1000) ? (this.value/1000 +'k') : (this.value))}
    end
  end


end