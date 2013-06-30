module ApplicationHelper
 
  def bootstrap_class_for flash_type
    case flash_type
      when :success then  "alert alert-success"
      when :error   then  "alert alert-error"
      when :alert   then  "alert alert-block"
      when :notice  then  "alert alert-info"
      else
        flash_type.to_s
    end
  end
 
end