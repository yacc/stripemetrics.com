require 'spec_helper'

describe Cohort do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:user) {User.make!} 
  let(:customers_23_json) {Rails.root.join("spec","fixtures","customers_23_objects.json")}
  let(:customers_9_json) {Rails.root.join("spec","fixtures","customers_9_objects.json")}

  context "matrix" do

    it "always exits for a user" do
      user.cohort.should_not be_nil
      user.cohort.matrix.should eq([])      
    end

    context "no cancellation" do
      it "should initialize the monthly cancellation by join month" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_23_json)
        cancellations = user.cohort.cancellations
        cancellations.should eq({})
      end
      it "should refresh the monthly cancellation by join month" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_9_json)
        cancellations = user.cohort.cancellations
        cancellations.should eq({})      
      end      
      it "should refresh the monthly cohort" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_9_json)
        status = user.cohort.refresh!
        status.should be(true)
        # just making sure the acquisition trend is initialized (or refreshed)
        user.acquisition_trend.monthly.should eq([[1362092400000, 1], [1364767200000, 1], [1367359200000, 1]])
        # retention is one, since there were no cancellation
        user.cohort.matrix.should eq([[1, 1, 1], [1, 1, 1], [1, 1, 1]])
      end      
    end

    context "with cancellations" do
      it "should report one cancellation" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_23_json)
        canceled_user = user.customers.first
        canceled_user.update_attribute(:canceled_at,Time.at(1361764656))
        cancellations = user.cohort.cancellations
        cancellations.should eq({1367359200000=>{1362092400000=>1}})      
      end
      it "should refresh the monthly cohort" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_23_json)
        canceled_user = user.customers.first
        cancel_at = 1364180256
        canceled_user.update_attribute(:canceled_at,cancel_at)
        status = user.cohort.refresh!
        status.should be(true)
        # making sure cancellations were updated
        user.cohort.cancellations.should eq({1367359200000=>{1364767200000=>1}})      
        # just making sure the acquisition trend is initialized (or refreshed)
        user.acquisition_trend.monthly.should eq([[1362092400000, 1], [1364767200000, 1], [1367359200000, 2]])
        user.cohort.matrix.should eq([[1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0, 0.5, 0.5]])
      end      
    end

  end    

end


