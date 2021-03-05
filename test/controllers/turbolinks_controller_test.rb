# frozen_string_literal: true

require "spec_helper"

describe TopicsController do
  let(:user) { create(:user) }
  let(:user1) { create(:user) }
  let(:headers) { {"User-Agent": "turbolinks-app, test"} }

  it "GET /topics/new should got 401 with turbolinks-app" do
    get new_topic_path, headers: headers
    assert_equal 401, response.status
  end

  describe "access with access_token" do
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:access_token1) { create(:access_token, resource_owner_id: user1.id) }

    it "should work" do
      get new_topic_path, params: {access_token: access_token.token}, headers: headers
      assert_equal 200, response.status
      assert_includes response.body, "New Topic"
      assert_includes response.body, "App.current_user_id = #{user.id}"
    end

    it "should work with other user" do
      get new_topic_path, params: {access_token: access_token1.token}, headers: headers
      assert_equal 200, response.status
      assert_includes response.body, "App.current_user_id = #{user1.id}"
    end
  end
end
