require 'spec_helper'

describe CohortTable do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:user) {User.make!} 
  let(:customers_23_json) {Rails.root.join("spec","fixtures","customers_23_objects.json")}
  let(:customers_9_json) {Rails.root.join("spec","fixtures","customers_9_objects.json")}

  context "monthly" do

    it "always exits for a user" do
      user.cohort_table.should_not be_nil
      user.cohort_table.monthly.should eq([])      
    end

    context "no cancellation" do
      it "should initialize the monthly cohort" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_23_json)
        cancellations = user.cohort_table.refresh_monthly
        cancellations.should eq([])
      end
      it "should refresh the monthly cohort" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_9_json)
        cancellations = user.cohort_table.refresh_monthly
        cancellations.should eq([])      
      end      
    end

    context "with cancellations" do
      it "should report one cancellation" do
        import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:customers_23_json)
        byebye = user.customers.first
        byebye.update_attribute(:canceled_at,Time.at(1361764656))
        cancellations = user.cohort_table.refresh_monthly
        cancellations.should eq([[1367391600000, 1362124800000, 1]])      
      end
    end

  end    

end


