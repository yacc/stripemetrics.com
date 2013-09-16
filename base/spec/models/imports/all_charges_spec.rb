require 'spec_helper'

describe ChargeImport do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:user) {User.make!} 
  let(:charges_23_json) {Rails.root.join("spec","fixtures","charge_all_response_from_stripe_23_objects.json")}
  let(:charges_9_json) {Rails.root.join("spec","fixtures","charge_all_response_from_stripe_9_objects.json")}
  let(:api_token) {'NsYmhRReX6amReKBK6cKBg60Xe9pyF6W'}
  let(:acharge) {import = user.charge_imports.create(end_at:1379357611,start_at:1379357612,token:api_token);Charge.last}

  context "should create a new import" do
    it "from start_at and end_at" do
      import = user.charge_imports.create(start_at:1368403200,end_at:1369007999,token:api_token)
      import.should be_valid
      import.start_at.to_i.should eq(1368403200)
      import.end_at.to_i.should eq(1369007999)
    end    
    it "from stripe" do
      import = user.charge_imports.create(start_at:1368403200,end_at:1369007999, mode: :from_stripe,token:api_token)
      import.should be_valid
      import.mode.should eq(:from_stripe)
      import.from_stripe_api?.should be_true
    end    
    it "from file" do
      import = user.charge_imports.create(start_at:1368403200,end_at:1369007999,mode: :from_file, file:charges_9_json)
      import.should be_valid
      import.mode.should eq(:from_file)
      import.file.should eq(charges_9_json.to_s)
      import.from_file?.should be_true
    end    
  end

  describe "should create" do
    it "6 objects from file" do
      lambda do 
        import = user.charge_imports.create(end_at:1370224410,start_at:1370282280,mode: :from_file,file:charges_9_json)
        import.reload.count.should eq(9)
      end.should change(Charge, :count).by(9)
    end    
    it "6 objects from api" do
      lambda do 
        import = user.charge_imports.create(end_at:1370224404,start_at:1370282280,token:api_token)
        import.reload.count.should eq(5)
      end.should change(Charge, :count).by(5)
    end    
    it "29 objects from api in 5 object bunch" do
      lambda do 
        import = user.charge_imports.create(:limit => 5,end_at:1370115404,start_at:1370282280,token:api_token)      
        import.reload.count.should eq(5) 
      end.should change(Charge, :count).by(28)
    end    
    it "29 objects from api in 10 object bunch" do
      lambda do 
        import = user.charge_imports.create(:limit => 10,end_at:1370115404,start_at:1370282280,token:api_token)      
        import.reload.count.should eq(10) 
      end.should change(Charge, :count).by(28)
    end    
  end

  describe "should persiste" do
    it "the created data" do
      acharge.created.should_not be_nil
    end
    it "the credit card" do
      acharge.should_not be_nil
      acharge.card.should_not be_nil
    end  
    it "the credit card type" do
      acharge.card.card_type.should_not be_nil
    end
    it "the credit card expiration date" do
      acharge.card.exp_month.should_not be_nil
      acharge.card.exp_year.should_not be_nil
    end
    it "the country" do
      acharge.card.country.should_not be_nil
    end
  end

end

