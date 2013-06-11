class SdeImportDirector < ImportDirector

  # after_create :start_first_import

  # def start_first_import
  #   logger.info "YYY: enqueueing SdeImportDirector for user #{self.user_id}"
  #   Resque.enqueue(ImportStripeSubscriptionDeletedEvents,self.user_id)  
  #   logger.info "YYY: just enqueued ImportStripeSubscriptionDeletedEvents for user #{self.user_id}"
  # end
  
end
