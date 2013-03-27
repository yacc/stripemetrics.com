class ImportJob
  
  def initialize(user_id,options = {})
    @offset         = 0
    @imported       = 0
    @count          = options["count"]  || 100
    @user           = User.find(user_id)
    @token          = user.token
    @last_processed = user.imports_summary.subscriptions_import_last_processed_ts
    @newest_import  = nil
  end

  def lock
    if user.imports_summary.subscriptions_import_locked
      raise "Skiping Subscriptions Canceled Events Import for #{user.id} b/c one is already running\n"
      return
    end
    user.imports_summary.subscriptions_import_locked = true
    user.imports_summary.save
    print "-> Start Events Import for #{user.id} from #{last_processed} to present\n"  
  end

  def run(&block)
    begin
      
    rescue Exception => e
    ensure

    end
  end

end
