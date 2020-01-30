# frozen_string_literal: true

require "spec_helper"

describe Api::V3::RepliesController do
  let(:reply) { create(:reply, user: current_user) }

  describe "GET /api/v3/replies/:id.json" do
    it "should be ok" do
      get "/api/v3/replies/#{reply.id}.json"
      assert_equal 200, response.status
      assert_has_keys json["reply"], "id", "topic_id", "user", "likes_count", "body", "body_html"
      assert_equal reply.id, json["reply"]["id"]
      assert_equal reply.body, json["reply"]["body"]
      assert_has_keys json["reply"]["abilities"], "update", "destroy"
      assert_equal false, json["reply"]["abilities"]["update"]
      assert_equal false, json["reply"]["abilities"]["destroy"]
    end

    it "should return right abilities when owner visit" do
      r = create(:reply, user: current_user)
      login_user!
      get "/api/v3/replies/#{r.id}.json"
      assert_equal 200, response.status
      assert_equal true, json["reply"]["abilities"]["update"]
      assert_equal true, json["reply"]["abilities"]["destroy"]
    end

    it "should return right abilities when admin visit" do
      login_admin!
      get "/api/v3/replies/#{reply.id}.json"
      assert_equal 200, response.status
      assert_equal true, json["reply"]["abilities"]["update"]
      assert_equal true, json["reply"]["abilities"]["destroy"]
    end
  end

  describe "POST /api/v3/replies/:id.json" do
    it "require login" do
      post "/api/v3/replies/#{reply.id}.json", body: "bar dar"
      assert_equal 401, response.status
    end

    it "require owner" do
      r = create(:reply)
      login_user!
      post "/api/v3/replies/#{r.id}.json", body: "bar dar"
      assert_equal 403, response.status
    end

    it "should work by owner" do
      login_user!
      post "/api/v3/replies/#{reply.id}.json", body: "bar dar"
      assert_equal 200, response.status
      reply.reload
      assert_equal "bar dar", json["reply"]["body"]
      assert_equal "bar dar", reply.body
    end

    it "should work by admin" do
      login_admin!
      r = create(:reply)
      post "/api/v3/replies/#{r.id}.json", body: "bar dar"
      assert_equal 200, response.status
    end
  end

  describe "DELETE /api/v3/replies/:id.json" do
    it "require login" do
      delete "/api/v3/replies/#{reply.id}.json"
      assert_equal 401, response.status
    end

    it "require owner" do
      r = create(:reply)
      login_user!
      delete "/api/v3/replies/#{r.id}.json"
      assert_equal 403, response.status
    end

    it "should work by owner" do
      login_user!
      delete "/api/v3/replies/#{reply.id}.json"
      assert_equal 200, response.status
      reply.reload
      assert_equal true, reply.deleted?
    end

    it "should work by admin" do
      login_admin!
      r = create(:reply)
      delete "/api/v3/replies/#{r.id}.json"
      assert_equal 200, response.status
      r.reload
      assert_equal true, r.deleted?
    end
  end
end
