# frozen_string_literal: true

require "rails_helper"

describe "API V3", "likes", type: :request do
  let!(:reply) { create(:reply) }
  let!(:topic) { create(:topic) }

  describe "POST /api/v3/likes.json" do
    it "require login" do
      post "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      expect(response.status).to eq(401)
    end

    it "should be ok" do
      login_user!
      old_count = reply.likes_count
      post "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      expect(response.status).to eq(200)
      expect(json).to include("obj_type", "obj_id", "count")
      reply.reload
      expect(reply.likes_count).to eq(old_count + 1)
      expect(json["count"]).to eq reply.likes_count
    end
  end

  describe "DELETE /api/v3/likes.json" do
    it "require login" do
      delete "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      expect(response.status).to eq(401)
    end

    it "should be ok" do
      login_user!
      reply.likes_count
      delete "/api/v3/likes.json", obj_type: "reply", obj_id: reply.id
      expect(response.status).to eq(200)
      expect(json).to include("obj_type", "obj_id", "count")
      reply.reload
      expect(reply.likes_count).to eq 0
      expect(json["count"]).to eq reply.likes_count
    end
  end
end
