require 'spec_helper'

describe "Imports" do
  describe Charge do

    it "should create a charge from a valid json" do
      json_obj = JSON.parse(File.read("./spec/fixtures/valid_charge.json"))
      charge = Charge.create(json_obj)

      charge.created.to_s.should eq("2013-03-17") #1363542779)
      charge.livemode.should eq(false)
      charge.paid.should eq(false)
      charge.amount.should eq(995)
      charge.currency.should eq("usd")
      charge.refunded.should eq(false)
      charge.fee.should eq(0)
      charge.captured.should eq(true)
      charge.amount_refunded.should eq(0)
      charge.dispute.should eq(nil)
    end

    it "should create a charge from a full json response form stripe" do
      json_obj = JSON.parse(File.read("./spec/fixtures/charge_response_from_stripe.json"))
      charge = Charge.create(json_obj)

      charge.created.to_s.should eq("2013-03-17") #1363542779)
      charge.livemode.should eq(false)
      charge.paid.should eq(false)
      charge.amount.should eq(995)
      charge.currency.should eq("usd")
      charge.refunded.should eq(false)
      charge.fee.should eq(0)
      charge.captured.should eq(true)
      charge.amount_refunded.should eq(0)
      charge.dispute.should eq(nil)
    end

  end
end

