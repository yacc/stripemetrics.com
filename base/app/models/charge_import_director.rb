class ChargeImportDirector < ImportDirector

  after_create :start_first_import

  def start_first_import
    Resque.enqueue(ImportStripeCharges,self.user.id,nil)  
  end
  
end
