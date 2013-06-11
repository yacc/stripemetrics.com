class CustomerImportDirector < ImportDirector

  # after_create :start_first_import

  # def start_first_import
  #   logger.info "YYY: enqueueing ImportStripeCustomers for user #{self.user_id}"
  #   Resque.enqueue(ImportStripeCustomers,self.user_id)  
  #   logger.info "YYY: just enqueued ImportStripeCustomers for user #{self.user_id}"
  # end
  
end
