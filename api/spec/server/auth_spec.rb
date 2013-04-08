require 'spec_helper'

describe Stripemetrics do
  include Rack::Test::Methods

  describe Stripemetrics::Api do
    describe 'POST /api/v1/auth/login' do
      it 'returns a token if credentials are valid' do
        yacin = double "yacin's double"
        User.should_receive(:authenticate).with('yacin@me.com','sekkret').and_return(yacin)

        post "/api/v1/auth/login?username=yacin@me.com&password=sekkret"

        last_response.status.should == 200
        JSON.parse(last_response.body)["token"].should == token
      end

      it 'returns an error if login is not found' do
        yacin = double "yacin's double"
        User.should_receive(:authenticate).with('yacin@me.com').and_return(nil)
        post "/api/v1/auth/login?username=yacin@me.com&password=sekkret"

        last_response.status.should == 404
        JSON.parse(last_response.body)["msg"].should == 'Wrong credentials - please check your email and password'
      end

      it 'returns an error if credentials are not valid' do
        yacin = double "yacin's double"
        User.should_receive(:authenticate).with('yacin@me.com','wrong_sekkret').and_return(nil)
        post "/api/v1/auth/login?username=yacin@me.com&password=wrong_sekkret"

        last_response.status.should == 401
        JSON.parse(last_response.body)["msg"].should == 'Wrong credentials - please check your email and password'
      end
    end
  end
end

# describe Token do
#   it 'should return a 401 with no basic auth to /api/v1/token' do
#     get '/api/v1/rewards'
#     response.code.should == '401'
#     response.body.should == "Unauthorized - Please check your username and password"
#   end
# end
