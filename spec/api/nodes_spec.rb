require 'rails_helper'
require 'active_support/core_ext'

describe RubyChina::API, "nodes", :type => :request do
  describe "GET /api/nodes.json" do
    before do
      %w(fun ruby nodes).each_with_index { |n, i| Factory(:node, :name => n, :id => i + 1) }
    end

    it "should return the list of nodes" do
      get "/api/nodes.json"
      expect(response.status).to eq(200)
      keyset = ["id","name"]
      json = JSON.parse(response.body).each {
        |h| h.slice!(*keyset)
      }

      expect(json).to eq([
        {"id" => 1, "name" => "fun"},
        {"id" => 2, "name" => "ruby"},
        {"id" => 3, "name" => "nodes"}
      ])
    end
  end
end
