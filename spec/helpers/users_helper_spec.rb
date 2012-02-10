require "spec_helper"

describe UsersHelper do
  describe "user_avatar_width_for_size" do
    it "should calculate avatar width correctly" do
      helper.user_avatar_width_for_size(:normal).should == 48
      helper.user_avatar_width_for_size(:small).should == 16
      helper.user_avatar_width_for_size(:large).should == 64
      helper.user_avatar_width_for_size(233).should == 233
    end
  end
end