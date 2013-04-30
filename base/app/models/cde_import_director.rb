class CdeImportDirector < ImportDirector

  after_create :start_first_import

  def start_first_import
    logger.info "YYY: enqueueing ImportStripeCustomerDeletedEvents for user #{self.user_id}"
    Resque.enqueue(ImportStripeCustomerDeletedEvents,self.user_id)  
    logger.info "YYY: just enqueued ImportStripeCustomerDeletedEvents for user #{self.user_id}"
  end
  
end
