require 'spec_helper'

describe "Imports" do
  describe Customer do

    it "should create a valid customer from a valid json" do
      json_obj = JSON.parse(File.read("./spec/fixtures/valid_customer.json"))
      cust = Customer.create(Customer.from_stripe(json_obj))

      cust.created.to_s.should eq("2013-03-24") 
      cust.stripe_id.should eq("cus_1WTl23tpQroXTl")
    end

    it "should create a valid subscription for a cust from a valid json" do
      json_obj = JSON.parse(File.read("./spec/fixtures/valid_customer.json"))
      cust = Customer.create(Customer.from_stripe(json_obj))

      sub = cust.subscription
      sub.start.to_s.should eq("2013-03-24") 
      sub.canceled_at.should eq(nil)
      sub.ended_at.should eq(nil)
      sub.status.should eq("trialing") 
      sub.plan.should be_nil
   end

  end
end

