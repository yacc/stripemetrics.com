require 'spec_helper'
require 'user'

describe Stripemetrics do
  include Rack::Test::Methods

  describe Stripemetrics::Api do
    describe 'POST /api/v1/auth' do
      it 'returns a token if credentials are valid' do
        yacin = double "yacin's double"
        User.should_receive(:find_by_email).with('yacin@me.com').and_return(yacin)
        yacin.should_receive(:authenticate).and_return(:true)
        auth = double "yacin's authorization"
        auth.should_receive(:token).and_return(SecureRandom.hex)
        Authorization.should_receive(:find_by_user).and_return(token)
        post "/api/v1/auth?login=yacin@me.com&password=sekkret"

        last_response.status.should == 200
        JSON.parse(last_response.body)["token"].should == token
      end

      it 'returns an error if login is not found' do
        yacin = double "yacin's double"
        User.should_receive(:find_by_email).with('yacin@me.com').and_return(nil)
        post "/api/v1/auth?login=yacin@me.com&password=sekkret"

        last_response.status.should == 404
        JSON.parse(last_response.body)["msg"].should == 'Wrong credentials - please check your email and password'
      end

      it 'returns an error if credentials are not valid' do
        yacin = double "yacin's double"
        User.should_receive(:find_by_email).with('yacin@me.com').and_return(yacin)
        yacin.should_receive(:authenticate).and_return(:false)
        post "/api/v1/auth?login=yacin@me.com&password=sekkret"

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
