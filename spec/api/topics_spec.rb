require 'spec_helper'

describe RubyChina::API, "topics" do
  describe "GET /api/topics" do
    it "should be ok" do
      get "/api/topics"
      response.status.should == 200
    end
  end
end
