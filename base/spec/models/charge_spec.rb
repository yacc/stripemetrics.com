require 'spec_helper'

describe Charge do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:customer) {Customer.make!} 
  let(:ch1) {Charge.make!(customer:customer.stripe_id,created:customer.created)}
  let(:ch2) {Charge.make!(customer:customer.stripe_id,created:customer.created+1.month)}
  let(:ch3) {Charge.make!(customer:customer.stripe_id,created:customer.created+2.month)}

  describe "with valid parameters" do
    it "should be persisted" do
      customer.should_not be_nil
      ch1.should_not be_nil
    end
  end

  describe "New Mrr" do
    it "is from false to true" do
      ch1.new_mrr.should be_false
      ch2.new_mrr.should be_false
      ch3.new_mrr.should be_false
      customer.refresh_new_mrr_flag
      ch1.reload.new_mrr.should be_true      
      ch2.reload.new_mrr.should be_false
      ch3.reload.new_mrr.should be_false
      customer.ts_4_newmrr.should eq(ch3.created)
      ch4 = Charge.make!(customer:customer.stripe_id,created:customer.created+3.month)
      customer.refresh_new_mrr_flag
      ch1.reload.new_mrr.should be_true      
      ch2.reload.new_mrr.should be_false
      ch3.reload.new_mrr.should be_false
      customer.reload.ts_4_newmrr.should eq(ch4.created)
    end
  end

end

