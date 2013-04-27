class CdeImportDirector < ImportDirector

  after_create :start_first_import

  def start_first_import
    Resque.enqueue(ImportStripeCustomerDeletedEvents,self.user.id,nil)  
  end
  
end
