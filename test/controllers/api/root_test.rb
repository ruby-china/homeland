# frozen_string_literal: true

require "spec_helper"
require "active_support/core_ext"

describe Api::V3::RootController do
  describe "Not found routes" do
    it "should return status 404" do
      get "/api/v3/foo-bar.json"
      assert_equal 404, response.status
      assert_equal "ResourceNotFound", json["error"]
    end
  end

  describe "GET /api/v3/hello.json" do
    it "without oauth2 should faild with 401" do
      get "/api/v3/hello.json"
      assert_equal 401, response.status
    end

    it "with oauth2 should work" do
      login_user!
      get "/api/v3/hello.json"
      assert_equal 200, response.status
      assert_equal current_user.id, json["user"]["id"]
      assert_equal current_user.login, json["user"]["login"]
      assert_equal current_user.name, json["user"]["name"]
      assert_equal true, json["user"]["avatar_url"].present?
    end
  end

  describe "Validation" do
    it "should status 400 and give Validation errors" do
      login_user!
      get "/api/v3/hello.json", limit: 2000
      assert_equal 400, response.status
      assert_equal "ParameterInvalid", json["error"]
    end
  end
end
