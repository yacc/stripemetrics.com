require 'resque/plugins/lock'

class ImportObjects
  @queue = :stripe_objects_import_queue

  def self.perform(import_id)
    import   = Import.find(import_id)  
    user     = import.user
    type     = import._type 
    import.run!
    # todo: test import.successfull?
    if import.did_not_import_all_objects_in_interval?
      case type
      when 'ChargeImport'
        user.charge_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      when 'CustomerImport'
        user.customer_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      when 'CdeImport'
        user.cde_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      when 'SdeImport'
        user.sde_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      end
    end
  end

end