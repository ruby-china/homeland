require 'spec_helper'

describe RubyChina::API, "nodes" do
  describe "GET /api/nodes.json" do
    before do
      %w(fun ruby nodes).each_with_index { |n, i| Factory(:node, :name => n, :_id => i + 1) }
    end

    it "should return the list of nodes" do
      get "/api/nodes.json"
      response.status.should == 200
      json = JSON.parse(response.body)
      json.should == [
        {"_id" => 1, "name" => "fun"},
        {"_id" => 2, "name" => "ruby"},
        {"_id" => 3, "name" => "nodes"}
      ]
    end
  end
end
