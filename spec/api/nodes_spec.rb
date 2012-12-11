require 'spec_helper'
require 'active_support/core_ext'

describe RubyChina::API, "nodes" do
  describe "GET /api/nodes.json" do
    before do
      %w(fun ruby nodes).each_with_index { |n, i| Factory(:node, :name => n, :id => i + 1) }
    end

    it "should return the list of nodes" do
      get "/api/nodes.json"
      response.status.should == 200
      keyset = ["id","name"]
      json = JSON.parse(response.body).each {
        |h| h.slice!(*keyset)
      }

      json.should == [
        {"id" => 1, "name" => "fun"},
        {"id" => 2, "name" => "ruby"},
        {"id" => 3, "name" => "nodes"}
      ]
    end
  end
end
