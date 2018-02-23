# frozen_string_literal: true

require "rails_helper"
require "active_support/core_ext"

describe "API V3", "nodes", type: :request do
  let(:json) { JSON.parse(response.body) }
  describe "GET /api/nodes.json" do
    before do
      %w[fun ruby nodes].each_with_index { |n, i| create(:node, name: n, id: i + 1) }
    end

    it "should return the list of nodes" do
      get "/api/v3/nodes.json"
      expect(response.status).to eq(200)
      keyset = %w[id name]
      expect(json).to include("nodes")
      expect(json["nodes"].size).to eq 3
      expect(json["nodes"][0]).to include("id", "name", "topics_count", "summary", "section_id", "sort", "section_name", "updated_at")
      json["nodes"].each do |h|
        h.slice!(*keyset)
      end

      expect(json["nodes"]).to eq([{ "id" => 1, "name" => "fun" },
                                   { "id" => 2, "name" => "ruby" },
                                   { "id" => 3, "name" => "nodes" }])
    end
  end

  describe "GET /api/nodes/:id.json" do
    let(:node) { create(:node, topics_count: 100) }

    it "should work" do
      get "/api/v3/nodes/#{node.id}.json"
      expect(response.status).to eq(200)
      expect(json["node"]).to include("id", "name", "topics_count", "summary", "section_id", "sort", "section_name", "updated_at")
      expect(json["node"]["topics_count"]).to eq(100)
    end
  end
end
