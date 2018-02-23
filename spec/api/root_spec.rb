# frozen_string_literal: true

require "rails_helper"
require "active_support/core_ext"

describe "API", type: :request do
  let(:json) { JSON.parse(response.body) }

  describe "Not found routes" do
    it "should return status 404" do
      get "/api/v3/foo-bar.json"
      expect(response.status).to eq 404
      expect(json["error"]).to eq "ResourceNotFound"
    end
  end

  describe "GET /api/v3/hello.json" do
    context "without oauth2" do
      it "should faild with 401" do
        get "/api/v3/hello.json"
        expect(response.status).to eq(401)
      end
    end

    context "Simple test with oauth2" do
      it "should work" do
        login_user!
        get "/api/v3/hello.json"
        expect(response.status).to eq 200
        expect(json["user"]).to include("id", "name", "login", "avatar_url")
        expect(json["meta"]).to include("time")
        expect(json["user"]["login"]).to eq current_user.login
        expect(json["user"]["name"]).to eq current_user.name
        expect(json["user"]["avatar_url"]).not_to be_nil
      end
    end

    describe "Validation" do
      it "should status 400 and give Validation errors" do
        login_user!
        get "/api/v3/hello.json", limit: 2000
        expect(response.status).to eq 400
        # puts json.inspect
        expect(json["error"]).to eq "ParameterInvalid"
      end
    end
  end
end
