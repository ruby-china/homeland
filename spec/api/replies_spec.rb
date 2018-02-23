# frozen_string_literal: true

require "rails_helper"

describe "API V3", "replies", type: :request do
  let!(:reply) { create(:reply, user: current_user) }

  describe "GET /api/v3/replies/:id.json" do
    it "should be ok" do
      get "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(200)
      expect(json["reply"]).to include("id", "topic_id", "user", "likes_count", "body", "body_html")
      expect(json["reply"]["id"]).to eq reply.id
      expect(json["reply"]["body"]).to eq reply.body
      expect(json["reply"]["abilities"]).to include("update", "destroy")
      expect(json["reply"]["abilities"]["update"]).to eq false
      expect(json["reply"]["abilities"]["destroy"]).to eq false
    end

    it "should return right abilities when owner visit" do
      r = create(:reply, user: current_user)
      login_user!
      get "/api/v3/replies/#{r.id}.json"
      expect(response.status).to eq(200)
      expect(json["reply"]["abilities"]["update"]).to eq true
      expect(json["reply"]["abilities"]["destroy"]).to eq true
    end

    it "should return right abilities when admin visit" do
      login_admin!
      get "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(200)
      expect(json["reply"]["abilities"]["update"]).to eq true
      expect(json["reply"]["abilities"]["destroy"]).to eq true
    end
  end

  describe "POST /api/v3/replies/:id.json" do
    it "require login" do
      post "/api/v3/replies/#{reply.id}.json", body: "bar dar"
      expect(response.status).to eq(401)
    end

    it "require owner" do
      r = create(:reply)
      login_user!
      post "/api/v3/replies/#{r.id}.json", body: "bar dar"
      expect(response.status).to eq(403)
    end

    it "should work by owner" do
      login_user!
      post "/api/v3/replies/#{reply.id}.json", body: "bar dar"
      expect(response.status).to eq(200)
      reply.reload
      expect(json["reply"]["body"]).to eq "bar dar"
      expect(reply.body).to eq "bar dar"
    end

    it "should work by admin" do
      login_admin!
      r = create(:reply)
      post "/api/v3/replies/#{r.id}.json", body: "bar dar"
      expect(response.status).to eq(200)
    end
  end

  describe "DELETE /api/v3/replies/:id.json" do
    it "require login" do
      delete "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(401)
    end

    it "require owner" do
      r = create(:reply)
      login_user!
      delete "/api/v3/replies/#{r.id}.json"
      expect(response.status).to eq(403)
    end

    it "should work by owner" do
      login_user!
      delete "/api/v3/replies/#{reply.id}.json"
      expect(response.status).to eq(200)
      reply.reload
      expect(reply.deleted_at).not_to eq nil
    end

    it "should work by admin" do
      login_admin!
      r = create(:reply)
      delete "/api/v3/replies/#{r.id}.json"
      expect(response.status).to eq(200)
      r.reload
      expect(r.deleted_at).not_to eq nil
    end
  end
end
