require 'spec_helper'

describe User do

  describe "new" do
    let(:user) do 
      User.create({"provider"=>"stripe_connect", "uid"=>"No2IOVL7FVAmLeUBQwCU4mklQ7lS51p5", 
                   "livemode"=>false, "token"=>"sk_test_rHrZMZsBcPbgmiklOR9oPbZo"})
    end

    it "should have a CDE import director" do
      user.cde_import_director.should_not be_nil
    end
    it "should have a SDE import director" do
      user.sde_import_director.should_not be_nil
    end
    it "should have a Charge import director" do
      user.charge_import_director.should_not be_nil
    end  
    it "should have a Customer import director" do
      user.customer_import_director.should_not be_nil
    end  
    it "should have one CDE import" do
      user.cde_import_director.imports.where(_type:CdeImportDirector).should_not be_nil
    end
    it "should have a SDE import director" do
      user.cde_import_director.imports.where(_type:SdeImportDirector).should_not be_nil
    end
    it "should have a Charge import director" do
      user.cde_import_director.imports.where(_type:ChargeImportDirector).should_not be_nil
    end  
    it "should have a Customer import director" do
      user.cde_import_director.imports.where(_type:CustomerImportDirector).should_not be_nil
    end  
  end  
end
