require 'rails_helper'
require 'active_support/core_ext'

describe "API", type: :request do
  let(:json) { JSON.parse(response.body) }
  
  describe 'Not found routes' do
    it 'should return status 404' do
      get "/api/v3/foo-bar.json"
      expect(response.status).to eq 404
      expect(json["error"]).to eq "Page not found."
    end
  end
  
  describe "GET /api/v3/hello.json" do
    context 'without oauth2' do
      it "should faild with 401" do
        get "/api/v3/hello.json"
        expect(response.status).to eq(401)
        expect(json["error"]).to eq "Access Token 无效"
      end
    end
    
    context 'with oauth2' do
      it 'should work' do
        login_user!
        get "/api/v3/hello.json"
        expect(response.status).to eq 200
        expect(json['current_user']).to eq current_user.login
      end
    end

  end
end
