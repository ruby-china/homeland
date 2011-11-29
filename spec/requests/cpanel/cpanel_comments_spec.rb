require 'spec_helper'

describe "Cpanel::Comments" do
  describe "GET /cpanel_comments" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get cpanel_comments_path
      response.status.should be(200)
    end
  end
end
