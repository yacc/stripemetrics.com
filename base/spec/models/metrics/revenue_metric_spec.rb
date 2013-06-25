require 'spec_helper'

describe RevenueMetric do
  let(:user) {User.make!} 

  it "should exits on a user" do
    user.revenue_metric.should_not be_nil
    user.revenue_metric.should be_valid
  end    

  describe "with enough historical data (more than six mo)" do
    let(:charges_monthly) do 
        [
          [1328083200000, 124.76], [1330588800000, 312.11], [1333263600000, 574.88],
          [1335855600000, 863.23], [1338534000000, 1303.4], [1341126000000, 1518.76],
          [1343804400000, 2439.17], [1346482800000, 4478.69], [1349074800000, 4652.6],
          [1351753200000, 7830.08], [1354348800000, 10061.84], [1357027200000, 7133.42],
          [1359705600000, 7190.16], [1362124800000, 6606.41], [1364799600000, 11826.65], 
          [1367391600000, 7842.08], [1370070000000, 7941.07], [1372662000000, 4892.26]
        ]
    end

    it "should compute the relative revenue change" do
      metric = user.revenue_metric
      metric.relative_change(charges_monthly).should eq(-0.6231905090898684)
    end    

    it "should compute the compound TSM" do
      metric = user.revenue_metric
      metric.tsm_average(charges_monthly[-6..-1]).should eq(-0.06216055315255675)
    end    

    it "should refresh the metric" do  
      user.paid_charge_count_trend.monthly = charges_monthly
      user.paid_charge_count_trend.save
      user.revenue_metric.refresh!.should be_true
      metric = user.revenue_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should eq(7941.07)
      metric.change.should eq(-0.6231905090898684)
      metric.tsm_avrg.should eq(-0.06216055315255675)
    end
  end
    
  describe "with 3 month of historical data" do
    let(:charges_monthly) do 
        [
          [1367391600000, 7842.08], [1370070000000, 7941.07], [1372662000000, 4892.26]
        ]
    end

    it "should set the metric to nil" do  
      user.paid_charge_count_trend.monthly = charges_monthly
      user.paid_charge_count_trend.save
      user.revenue_metric.refresh!.should be_true
      metric = user.revenue_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should eq(7941.07)
      metric.change.should be_nil
      metric.tsm_avrg.should be_nil
    end
  end

  describe "with 1 month of historical data" do
    let(:charges_monthly) {[[1372662000000, 4892.26]]}

    it "should set the metric to nil" do  
      user.paid_charge_count_trend.monthly = charges_monthly
      user.paid_charge_count_trend.save
      user.revenue_metric.refresh!.should be_true
      metric = user.revenue_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should be_nil
      metric.change.should be_nil
      metric.tsm_avrg.should be_nil
    end
  end

end


