require 'spec_helper'

describe Stripemetrics do
  include Rack::Test::Methods

  describe Stripemetrics::Api do
    describe 'POST /v1/auth/login' do
      before(:all) do
        User.delete_all
        @yacin = User.create!(email:'yacin@me.com',password:'sekkret')
      end
      it 'returns a token if credentials are valid' do
        get "/v1/auth/login?username=yacin@me.com&password=sekkret"
        last_response.status.should == 200
        JSON.parse(last_response.body)["token"].should == @yacin.api_token
      end
      it 'returns an error if login is not found' do
        get "/v1/auth/login?username=notauser@me.com&password=sekkret"
        last_response.status.should == 401
        JSON.parse(last_response.body)['error'].should == 'Unauthorized'
      end
      it 'returns an error if credentials are not valid' do
        get "/v1/auth/login?username=yacin@me.com&password=wrong_sekkret"
        last_response.status.should == 401
        JSON.parse(last_response.body)['error'].should == 'Unauthorized'
      end
      it 'is not authorized to make an api call with no token' do
        get "/v1/auth/ping?api_token=invalid_token_shoot"
        last_response.status.should == 401
        JSON.parse(last_response.body)["error"].should == "Unauthorized"        
      end
      it 'successfuly uses the token to make an api call' do
        get "/v1/auth/login?username=yacin@me.com&password=sekkret"
        last_response.status.should == 200
        JSON.parse(last_response.body)["token"].should == @yacin.api_token
        get "/v1/auth/ping?api_token=#{@yacin.api_token}"
        last_response.status.should == 200
        JSON.parse(last_response.body)["message"].should == "pong"        
      end

    end
  end
end