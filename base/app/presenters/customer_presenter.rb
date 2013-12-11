class CustomerPresenter

  def self.attributes_to_display
    list = Customer.last.attributes.keys
    list.delete "_id"
    list.delete "object"
    list.delete "user_id"
    list.delete "livemode"
    list.delete "subscription"
    list.delete "active_card"
    list.delete "default_card"
    list
  end

  def initialize(customer=nil,options={})
    @customer = customer
    @options = options
  end
  
  def as_json(options={})
    @options.merge!(options)
    @customer.as_json(only:CustomerPresenter.attributes_to_display)
  end

  def as_array(options={})
    @options.merge!(options)
    cust =  @customer.as_json(only:CustomerPresenter.attributes_to_display)
    array = []
    CustomerPresenter.attributes_to_display.each do |attr|
      array << cust[attr]
    end
    array
  end

end

