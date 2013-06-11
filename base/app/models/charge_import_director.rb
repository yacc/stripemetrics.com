class ChargeImportDirector < ImportDirector

  # after_create :start_first_import

  # def start_first_import
  #   logger.info "YYY: enqueueing ImportStripeCharges for user #{self.user_id}"
  #   Resque.enqueue(ImportStripeCharges,self.user_id)  
  #   logger.info "YYY: just enqueued ImportStripeCharges for user #{self.user_id}"
  # end
  
end
