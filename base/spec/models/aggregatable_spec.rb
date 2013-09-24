require 'spec_helper'

describe Aggregatable do
	let(:user)  {User.make!}
	let(:trend) {Trend.make!(user_id:user.id)}

	it "should respond to data_source" do
		trend.respond_to? :data_source
	end

	it "should respond to aggregate_data" do
		trend.respond_to? :aggregate_data
	end

	describe "with wrong attributes" do
		pending "should raise a 'syntax error in m_criteria'" do |variable|
			trend.update_attributes(m_criteria:{"paid"=>true,"captured"=>true,"new_mrr"=>true})
		end
		pending "should raise a 'syntax error in p_criteria'" do |variable|
			trend.update_attributes(p_criteria:{"amount"=>"$amount"})			
		end
	end

	describe "match" do
		it "should scope by current user\'s" do
			match = {"$match"=>{"user_id"=>trend.user_id}}
			trend.send(:match).should be_eql match
		end
		it "should target new paid charges" do
			trend.update_attributes(m_criteria:{"paid"=>true,"captured"=>true,"new_mrr"=>true})
			match = {"$match"=>{"paid"=>true, "captured"=>true, "new_mrr"=>true, "user_id"=>trend.user_id}}
			trend.send(:match).should eq(match)
		end
	end

	describe "with unit amount" do
		it "should project amount and use created" do
			project = {"$project"=>{"amount"=>"$amount", 
				                      "year"=>{"$year"=>"$created"}, 
				                      "month"=>{"$month"=>"$created"}}}
			trend.update_attributes(groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
			trend.send(:project).should eq(project)
		end
		it "should project amount and use canceled" do
			project = {"$project"=>{"amount"=>"$amount", 
				                      "year"=>{"$year"=>"$canceled"}, 
				                      "month"=>{"$month"=>"$canceled"}}}
			trend.update_attributes(groupby_ts:"canceled",p_criteria:{"amount"=>"$amount"})	                      
			trend.send(:project).should eq(project)
		end
		it "should project subscription amount and " do
			project = {"$project"=>{"amount"=>"$subscription.plan.amount", 
				                      "year"=>{"$year"=>"$created"}, 
				                      "month"=>{"$month"=>"$created"}}}
			trend.update_attributes(groupby_ts:"created",p_criteria:{"amount"=>"$subscription.plan.amount"})
			trend.send(:project).should eq(project)
		end
	end

	describe "with dimension" do
		it "\"country\" should group by country" do
			trend.update_attributes(dimension:'country',groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
			trend.send(:id_key).should eq({"year"=>"$year", "month"=>"$month","country"=>"$country"})
		end				
		it "\"cc_type\" should group by cc_type" do
			trend.update_attributes(dimension:'cc_type',groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
			trend.send(:id_key).should eq({"year"=>"$year", "month"=>"$month","cc_type"=>"$cc_type"})
		end				
		it "\"plan_type\" should group by plan_type" do
			trend.update_attributes(dimension:'plan_type',groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
			trend.send(:id_key).should eq({"year"=>"$year", "month"=>"$month","plan_type"=>"$plan_type"})
		end				
	end

	describe "with unit" do
		it "\"count\" should sum by count" do
			trend.update_attributes(unit:'count',groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
		  trend.send(:total).should eq({ "$sum" => 1 } )
		end				
		it "\"amount\" should sum by amount" do
			trend.update_attributes(unit:'amount',groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
		  trend.send(:total).should eq({ "$sum" => "$amount" })
		end				
	end

	describe "process! with no dimension" do
		it "should call \"aggregate_by_month\" ounce" do
			trend.update_attributes(dimension: nil,groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
			trend.should_receive(:aggregate_by_month)
			trend.process!
		end

		it "should generate total mrr trend" do
			2.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-06-01"))}
			4.times {Charge.make!(user_id:user.id,created:Time.parse("2013-06-01"))}

			2.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-07-01"))}
			3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-07-01"))}

			1.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-08-01"))}
			3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-08-01"))}
			3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-09-01"))}

			newmrr = Trend.make!(user_id:user.id,type:"new_mrr",group:"mrr",name:"New MRR",
                           desc:"Monthly recuring revenue from new customers",
                           unit:"amount",source:"charges",interval:'month',
                           p_criteria:{"amount"=>"$amount"}, 
                           m_criteria:{},
                           groupby_ts:%Q|created|)
			Charge.where(paid:true,captured:true,new_mrr:true,user_id:user.id).count.should == 5
			newmrr.data_source.find.count.should == 18
			newmrr.process!
			newmrr.data.should eq({1372662000=>27000, 1380610800=>13500, 1378018800=>18000, 1375340400=>22500})
		end

		it "should generate new_mrr trend" do
			2.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-06-01"))}
			4.times {Charge.make!(user_id:user.id,created:Time.parse("2013-06-01"))}

			2.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-07-01"))}
			3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-07-01"))}

			1.times {Charge.make!(new_mrr: true,user_id:user.id,created:Time.parse("2013-08-01"))}
			3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-08-01"))}
			3.times {Charge.make!(user_id:user.id,created:Time.parse("2013-09-01"))}

			newmrr = Trend.make!(user_id:user.id,type:"new_mrr",group:"mrr",name:"New MRR",
                           desc:"Monthly recuring revenue from new customers",
                           unit:"amount",source:"charges",interval:'month',
                           p_criteria:{"amount"=>"$amount"}, 
                           m_criteria:{"paid"=>true,"captured"=>true,"new_mrr"=>true},
                           groupby_ts:%Q|created|)
			Charge.where(paid:true,captured:true,new_mrr:true,user_id:user.id).count.should == 5
			newmrr.data_source.find.count.should == 18
			newmrr.process!
			newmrr.data.should eq({1375340400=>9000, 1372662000=>9000, 1378018800=>4500})
		end

	end

	describe "process! with \"country\" dimension" do
		it "should call \"aggregate_by_month_and_dimension\" ounce" do
			trend.update_attributes(dimension:'country',groupby_ts:"created",p_criteria:{"amount"=>"$amount"})
			trend.should_receive(:aggregate_by_month_and_dimension)
			trend.process!
		end

		it "should aggregate charge amount by month cancelled"

	end

end
