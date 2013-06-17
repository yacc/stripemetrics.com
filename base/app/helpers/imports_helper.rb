module ImportsHelper

  def last_ran(imports)
    imports.last.created_at ? "#{distance_of_time_in_words(Time.now, imports.last.created_at)} ago" : 'unknown'
  end

  def oldest_object(imports)
    imports.last.last_imported_ts ? "#{distance_of_time_in_words(Time.now, imports.last.last_imported_ts)} ago" : 'unknown'     
  end

end