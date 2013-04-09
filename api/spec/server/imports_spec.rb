require 'spec_helper'

describe Stripemetrics do
  include Rack::Test::Methods

  describe Stripemetrics::Api do
    describe 'GET /v1/imports' do
      before(:all) do
        User.delete_all
        @yacin = User.create!(email:'yacin@me.com',password:'sekkret')
      end
      it 'with no token returns unauthorized' do
        get "/v1/imports"
        last_response.status.should == 401
        JSON.parse(last_response.body)["error"].should == "Unauthorized"        
      end
      it 'with tokens returns a list of imports' do
        get "/v1/imports?api_token=#{@yacin.api_token}"
        last_response.status.should == 200
        JSON.parse(last_response.body).should == [
          {"last_ran_at"=>nil, "last_processed_ts"=>nil, "imports"=>[]},
          {"last_ran_at"=>nil, "last_processed_ts"=>nil, "imports"=>[]},
          {"last_ran_at"=>nil, "last_processed_ts"=>nil, "imports"=>[]},
          {"last_ran_at"=>nil, "last_processed_ts"=>nil, "imports"=>[]}
        ]
      end
    end
  end
end