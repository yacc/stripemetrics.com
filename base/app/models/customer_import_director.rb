class CustomerImportDirector < ImportDirector

  after_create :start_first_import

  def start_first_import
    Resque.enqueue(ImportStripeCustomers,self.user.id,nil)  
  end
  
end
