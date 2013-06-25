module ImportsHelper

  def last_ran(imports)
    imports.last.created_at ? "#{distance_of_time_in_words(Time.now, imports.last.created_at)} ago" : 'unknown'
  end

  def oldest_object(imports)
    oldest = imports.desc(:start_at).last.last_imported_ts
    oldest ? "#{distance_of_time_in_words(Time.now, oldest)} ago" : 'unknown'     
  end

  def newest_object(imports)
    newest = imports.desc(:start_at).first.start_at
    newest ? "#{distance_of_time_in_words(Time.now, newest)} ago" : 'unknown'     
  end

end
