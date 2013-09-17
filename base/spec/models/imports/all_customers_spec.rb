require 'spec_helper'

describe CustomerImport do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:user) {User.make!} 
  let(:customers_23_json) {Rails.root.join("spec","fixtures","charge_all_response_from_stripe_23_customers.json")}
  let(:customers_9_json) {Rails.root.join("spec","fixtures","charge_all_response_from_stripe_9_customers.json")}
  let(:api_token) {'NsYmhRReX6amReKBK6cKBg60Xe9pyF6W'}
  let(:acustomer) {import = user.customer_imports.create(end_at:1375825457,start_at:1375825458,token:api_token);Customer.last}

  describe "should create a new import" do
    it "from start_at and end_at", :vcr do
      import = user.customer_imports.create(start_at:1368403200,end_at:1369007999,token:api_token)
      import.should be_valid
      import.start_at.to_i.should eq(1368403200)
      import.end_at.to_i.should eq(1369007999)
    end    
    it "from stripe", :vcr  do
      import = user.customer_imports.create(start_at:1368403200,end_at:1369007999, mode: :from_stripe,token:api_token)
      import.should be_valid
      import.mode.should eq(:from_stripe)
      import.from_stripe_api?.should be_true
    end    
  end

  describe "should create" do
    it "10 objects from api", :vcr do
      lambda do 
        import = user.customer_imports.create(end_at:1375825407,start_at:1375825450,token:api_token)
        import.reload.count.should eq(10)
      end.should (change(Customer, :count).by(15) and change(CustomerImport, :count).by(2))
    end    
    it "1 objects from api in 5 object bunch", :vcr do
      lambda do 
        import = user.customer_imports.create(limit:3,end_at:1375825407,start_at:1375825450,token:api_token)      
        import.reload.count.should eq(3) 
      end.should (change(Customer, :count).by(15) and change(CustomerImport, :count).by(5)) 
    end    
  end

  describe "should persiste" do
    it "the subscription", :vcr do
      acustomer.should_not be_nil
      acustomer.subscription.should_not be_nil
    end  
    it "the plan", :vcr do
      acustomer.subscription.plan.should_not be_nil
    end
  end
    
end
