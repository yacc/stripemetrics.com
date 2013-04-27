require 'spec_helper'

describe User do
  let(:user) {User.make!} 

  describe "new with valid data" do
    it "should have four import directors" do
      user.import_directors.size.should eq(4)
    end
    it "should have a CDE import director" do
      user.import_directors.where(type :ImportStripeCustomers).size.should eq(1)
    end
    it "should have a SDE import director"
    it "should have a Charge import director"
    it "should have a Customer import director"
  end  
end
