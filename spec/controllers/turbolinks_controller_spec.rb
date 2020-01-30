# frozen_string_literal: true

require "rails_helper"

describe TopicsController, type: :controller do
  let(:user) { create(:user) }
  let(:user1) { create(:user) }

  before do
    request.env["HTTP_USER_AGENT"] = "turbolinks-app, rspec"
  end

  it "should got 401 with turbolinks-app" do
    get :new
    refute_equal 200, response.status
    assert_equal 401, response.status
  end

  describe "access with access_token" do
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:access_token1) { create(:access_token, resource_owner_id: user1.id) }

    it "should work" do
      get :new, params: { access_token: access_token.token }
      assert_equal 200, response.status
      assert_includes response.body, "发布新话题"
      assert_includes response.body, "App.current_user_id = #{user.id}"
    end

    it "should work with other user" do
      get :new, params: { access_token: access_token1.token }
      assert_equal 200, response.status
      assert_includes response.body, "App.current_user_id = #{user1.id}"
    end
  end
end
