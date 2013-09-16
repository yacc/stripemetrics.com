require 'spec_helper'

describe CdeImport do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:user) {User.make!} 
  let(:api_token) {'NsYmhRReX6amReKBK6cKBg60Xe9pyF6W'}

  context "should create a new import" do
    it "from start_at and end_at" do
      import = user.cde_imports.create(start_at:1368403200,end_at:1369007999,token:api_token)
      import.should be_valid
      import.start_at.to_i.should eq(1368403200)
      import.end_at.to_i.should eq(1369007999)
    end    
    it "from stripe" do
      import = user.cde_imports.create(start_at:1368403200,end_at:1369007999, mode: :from_stripe,token:api_token)
      import.should be_valid
      import.mode.should eq(:from_stripe)
      import.from_stripe_api?.should be_true
    end    
  end

  describe "should create" do
    it "1 objects from api" do
      lambda do 
        import = user.cde_imports.create(end_at:1316197169,start_at:1379355565,token:api_token)
        import.reload.count.should eq(5)
      end.should (change(Customer, :count).by(5) and change(CdeImport, :count).by(1))
    end    
    it "1 objects from api in 5 object bunch" do
      lambda do 
        import = user.cde_imports.create(limit:3,end_at:1316197169,start_at:1379355565,token:api_token)      
        import.reload.count.should eq(3) 
      end.should (change(Customer, :count).by(5) and change(CdeImport, :count).by(2)) 
    end    
  end

end
