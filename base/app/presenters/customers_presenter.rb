class CustomersPresenter

  def initialize(customers)
    @customers = customers
  end

  def as_json(options={})
    @rows = []
    @customers.each_with_index.collect do |customer,index| 
        @rows <<  { id: index, cell: CustomerPresenter.new(customer).as_array}
    end

    json = {
      page:1,
      total:100,
      records:@customers.size,
      rows: @rows
    }
  end

end
