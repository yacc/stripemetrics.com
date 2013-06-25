require 'spec_helper'

describe CancellationMetric do
  let(:user) {User.make!} 

  it "should exits on a user" do
    user.cancellation_metric.should_not be_nil
    user.cancellation_metric.should be_valid
  end    

  describe "with enough historical data (more than six mo)" do
    let(:cancellation_monthly) do 
        [
          [1330588800000, 43], [1333263600000, 44], [1335855600000, 55],
          [1338534000000, 50], [1341126000000, 51], [1343804400000, 58],
          [1346482800000, 44], [1349074800000, 67], [1351753200000, 10477],
          [1354348800000, 330], [1357027200000, 238], [1359705600000, 166],
          [1362124800000, 122], [1364799600000, 108], [1367391600000, 114],
          [1370070000000, 91], [1372662000000, 68]
        ]
    end

    it "should compute the change in churn" do
      metric = user.cancellation_metric
      metric.relative_change(cancellation_monthly).should eq(-0.3382352941176471)
    end    

    it "should compute the compound TSM" do
      metric = user.cancellation_metric
      metric.tsm_average(cancellation_monthly[-6..-1]).should eq(-0.1382126052234457)
    end    

    it "should refresh the metric" do  
      user.cancellation_trend.monthly = cancellation_monthly
      user.cancellation_trend.save
      user.cancellation_metric.refresh!.should be_true
      metric = user.cancellation_metric.reload
      metric.this_month.should eq(68)
      metric.last_month.should eq(91)
      metric.change.should eq(-0.3382352941176471)
      metric.tsm_avrg.should eq(-0.1382126052234457)
    end
  end
    
  describe "with 3 month of historical data" do
    let(:cancellation_monthly) do 
        [
          [1367391600000, 7842.08], [1370070000000, 7941.07], [1372662000000, 4892.26]
        ]
    end

    it "should set the metric to nil" do  
      user.cancellation_trend.monthly = cancellation_monthly
      user.cancellation_trend.save
      user.cancellation_metric.refresh!.should be_true
      metric = user.cancellation_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should eq(7941.07)
      metric.change.should be_nil
      metric.tsm_avrg.should be_nil
    end
  end

  describe "with 1 month of historical data" do
    let(:cancellation_monthly) {[[1372662000000, 4892.26]]}

    it "should set the metric to nil" do  
      user.cancellation_trend.monthly = cancellation_monthly
      user.cancellation_trend.save
      user.cancellation_metric.refresh!.should be_true
      metric = user.cancellation_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should be_nil
      metric.change.should be_nil
      metric.tsm_avrg.should be_nil
    end
  end

end




