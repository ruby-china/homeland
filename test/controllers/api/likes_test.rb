# frozen_string_literal: true

require "spec_helper"

describe Api::V3::LikesController do
  let(:reply) { create(:reply) }
  let(:topic) { create(:topic) }

  describe "POST /api/v3/likes.json" do
    it "require login" do
      post "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      assert_equal 401, response.status
    end

    it "should be ok" do
      login_user!
      old_count = reply.likes_count
      post "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      assert_equal 200, response.status
      assert_has_keys json, "obj_type", "obj_id", "count"
      reply.reload
      assert_equal old_count + 1, reply.likes_count
      assert_equal reply.likes_count, json["count"]
    end
  end

  describe "DELETE /api/v3/likes.json" do
    it "require login" do
      delete "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      assert_equal 401, response.status
    end

    it "should be ok" do
      login_user!
      reply.likes_count
      delete "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      assert_equal 200, response.status
      assert_has_keys json, "obj_type", "obj_id", "count"
      reply.reload
      assert_equal 0, reply.likes_count
      assert_equal reply.likes_count, json["count"]
    end
  end
end
