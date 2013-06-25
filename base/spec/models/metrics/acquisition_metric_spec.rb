require 'spec_helper'

describe AcquisitionMetric do
  let(:user) {User.make!} 

  it "should exits on a user" do
    user.acquisition_metric.should_not be_nil
    user.acquisition_metric.should be_valid
  end    

  describe "with enough historical data (more than six mo)" do
    let(:acquisition_monthly) do 
        [
          [1328083200000, 5242], [1330588800000, 422], [1333263600000, 575], 
          [1335855600000, 688], [1338534000000, 817], [1341126000000, 819], 
          [1343804400000, 421], [1346482800000, 159], [1349074800000, 123], 
          [1351753200000, 10731], [1354348800000, 1009], [1357027200000, 871], 
          [1359705600000, 919], [1362124800000, 758], [1364799600000, 782], 
          [1367391600000, 643], [1370070000000, 635], [1372662000000, 466]
        ]
    end

    it "should compute the relative acquisition change" do
      metric = user.acquisition_metric
      metric.relative_change(acquisition_monthly).should eq(-0.3626609442060086)
    end    

    it "should compute the compound TSM" do
      metric = user.acquisition_metric
      metric.tsm_average(acquisition_monthly[-6..-1]).should eq(-0.10701314182653465)
    end    

    it "should refresh the metric" do  
      user.acquisition_trend.monthly = acquisition_monthly
      user.acquisition_trend.save
      user.acquisition_metric.refresh!.should be_true
      metric = user.acquisition_metric.reload
      metric.this_month.should eq(466)
      metric.last_month.should eq(635)
      metric.change.should eq(-0.3626609442060086)
      metric.tsm_avrg.should eq(-0.10701314182653465)
    end
  end
    
  describe "with 3 month of historical data" do
    let(:acquisition_monthly) do 
        [
          [1367391600000, 7842.08], [1370070000000, 7941.07], [1372662000000, 4892.26]
        ]
    end

    it "should set the metric to nil" do  
      user.acquisition_trend.monthly = acquisition_monthly
      user.acquisition_trend.save
      user.acquisition_metric.refresh!.should be_true
      metric = user.acquisition_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should eq(7941.07)
      metric.change.should be_nil
      metric.tsm_avrg.should be_nil
    end
  end

  describe "with 1 month of historical data" do
    let(:acquisition_monthly) {[[1372662000000, 4892.26]]}

    it "should set the metric to nil" do  
      user.acquisition_trend.monthly = acquisition_monthly
      user.acquisition_trend.save
      user.acquisition_metric.refresh!.should be_true
      metric = user.acquisition_metric.reload
      metric.this_month.should eq(4892.26)
      metric.last_month.should be_nil
      metric.change.should be_nil
      metric.tsm_avrg.should be_nil
    end
  end

end

