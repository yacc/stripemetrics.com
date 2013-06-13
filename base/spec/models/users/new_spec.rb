require 'spec_helper'

describe User do

  describe "new" do
    let(:user) do 
      User.create({"provider"=>"stripe_connect", "uid"=>"No2IOVL7FVAmLeUBQwCU4mklQ7lS51p5", 
                   "livemode"=>false, "token"=>"sk_test_rHrZMZsBcPbgmiklOR9oPbZo"})
    end

    it "should have one CDE import" do
      user.cde_imports.should_not be_nil
    end
    it "should have a SDE import" do
      user.sde_imports.should_not be_nil
    end
    it "should have a Charge import" do
      user.charge_imports.should_not be_nil
    end  
    it "should have a Customer import" do
      user.customer_imports.should_not be_nil
    end  
  end  
end
