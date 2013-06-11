require 'spec_helper'

describe ChargeImport do
  describe "creates new import"  do

    it "from start and end date" do
      json_obj = JSON.parse(File.read("./spec/fixtures/charge_all_response_from_stripe.json"))
      import = ChargeImport.create({status:'processing',start_at:1369007999,end_at:1369007999})
      import.
    end

  end
end

