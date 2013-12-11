class ChargePresenter

  def self.attributes_to_display
    list = Charge.last.attributes.keys
    list.delete "object"
    list.delete "_id"
    list.delete "card"
    list.delete "livemode"
    list.delete "user_id"
    list.delete "new_mrr"
    list.delete "balance_transaction"
    list.delete "failure_message"
    list.delete "description"
    list
  end

  def initialize(charge=nil,options={})
    @charge = charge
    @options = options
  end
  
  def as_json(options={})
    @options.merge!(options)
    @charge.as_json(only:ChargePresenter.attributes_to_display)
  end

  def as_array(options={})
    @options.merge!(options)
    charge =  @charge.as_json(only:ChargePresenter.attributes_to_display)
    array = []
    ChargePresenter.attributes_to_display.each do |attr|
      array << ((attr == 'amount' || attr == 'fee') ? charge[attr].to_f/100 : charge[attr])
    end
    array
  end

end
