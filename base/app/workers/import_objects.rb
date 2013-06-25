class ImportObjects

  def self.perform(import_id)
    import   = Import.find(import_id)  
    user     = import.user
    type     = import._type 
    import.run!
    # todo: test import.successfull?

    case type
    when 'ChargeImport'
      Resque.enqueue(UpdateChargeTrends, user.id)
      if import.did_not_import_all_objects_in_interval?
        user.charge_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      end
    when 'CustomerImport'
      Resque.enqueue(UpdateCustomerTrends, user.id)
      if import.did_not_import_all_objects_in_interval?
        user.customer_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      end
    when 'CdeImport'
      Resque.enqueue(UpdateCustomerTrends, user.id)
      if import.did_not_import_all_objects_in_interval?
        user.cde_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)       
      end   
    when 'SdeImport'
      Resque.enqueue(UpdateCustomerTrends, user.id)
      if import.did_not_import_all_objects_in_interval?
        user.sde_imports.create(start_at:import.last_imported_ts,end_at:import.end_at,token:import.token,limit:import.limit)        
      end
    end

    user.refresh_metrics
    
  end

end