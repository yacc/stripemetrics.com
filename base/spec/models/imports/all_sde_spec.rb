require 'spec_helper'

describe SdeImport do
  around(:each) do |example|
    resque_state = Resque.inline
    Resque.inline = true
    example.run
    Resque.inline = resque_state
  end

  let(:user) {User.make!(:basic)} 
  let(:api_token) {'NsYmhRReX6amReKBK6cKBg60Xe9pyF6W'}

  context "should create a new import" do
    it "from start_at and end_at" do
      import = user.sde_imports.create(start_at:1368403200,end_at:1369007999,token:api_token)
      import.should be_valid
      import.start_at.to_i.should eq(1368403200)
      import.end_at.to_i.should eq(1369007999)
    end    
    it "from stripe" do
      import = user.sde_imports.create(start_at:1368403200,end_at:1369007999, mode: :from_stripe,token:api_token)
      import.should be_valid
      import.mode.should eq(:from_stripe)
      import.from_stripe_api?.should be_true
    end    
  end

  describe "should create" do
    it "2 objects from api" do
      lambda do 
        import = user.sde_imports.create(start_at:1375825277,end_at:1368668811,token:api_token)
        import.reload.count.should eq(2)
      end.should change(Customer, :count).by(2)
    end    
    it "11 objects from api (in default chunk size of 10 using 2 imports)" do
      lambda {
        import = user.sde_imports.create(start_at:1375825277,end_at:1363446679,token:api_token)      
        import.reload.count.should eq(10)         
      }.should (change(Customer, :count).by(11) and change(SdeImport,:count).by(2))
    end    
    it "11 objects from api (in default chunk size of 3 using 4 imports)" do
      lambda {
        import = user.sde_imports.create(limit:3, start_at:1375825277,end_at:1363446679,token:api_token)      
        import.reload.count.should eq(3)         
      }.should (change(Customer, :count).by(11) and change(SdeImport,:count).by(4))
    end    
  end

end
