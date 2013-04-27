class SdeImportDirector < ImportDirector

  after_create :start_first_import

  def start_first_import
    Resque.enqueue(ImportStripeSubscriptionDeletedEvents,self.user.id,nil)  
  end
  
end
