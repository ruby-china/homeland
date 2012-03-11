require 'spec_helper'

describe RubyChina::API, "topics" do
  describe "GET /api/topics.json" do
    it "should be ok" do
      get "/api/topics.json"
      response.status.should == 200
    end
  end
end
