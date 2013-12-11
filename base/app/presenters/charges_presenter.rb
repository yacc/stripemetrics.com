class ChargesPresenter

  def initialize(charges)
    @charges = charges
  end

  def as_json(options={})
    @rows = []
    @charges.each_with_index.collect do |charge,index| 
        @rows <<  { id: index, cell: ChargePresenter.new(charge).as_array}
    end

    json = {
      page:1,
      total:100,
      records:@charges.size,
      rows: @rows
    }
  end

end
