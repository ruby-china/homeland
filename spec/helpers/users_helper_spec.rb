# coding: utf-8
require "spec_helper"

describe UsersHelper do
  describe "user_avatar_width_for_size" do
    it "should calculate avatar width correctly" do
      helper.user_avatar_width_for_size(:normal).should == 48
      helper.user_avatar_width_for_size(:small).should == 16
      helper.user_avatar_width_for_size(:large).should == 64
      helper.user_avatar_width_for_size(:big).should == 120
      helper.user_avatar_width_for_size(233).should == 233
    end
  end

  describe "user_name_tag" do
    it "should result right html in normal" do
      user = Factory(:user)
      helper.user_name_tag(user).should == link_to(user.login, user_path(user.login), 'data-name' => user.name)
    end

    it "should result right html with string param" do
      login = "Monster"
      helper.user_name_tag(login).should == link_to(login, user_path(login), 'data-name' => login)
    end

    it "should result empty with nil param" do
      helper.user_name_tag(nil).should == "匿名"
    end
  end

  describe "user personal website" do
    let(:user) { Factory(:user, :website => 'http://example.com') }
    subject { helper.render_user_personal_website(user) }

    it { should == link_to(user.website, user.website, :target => "_blank", :rel => "nofollow") }

    context "url without protocal" do
      before { user.update_attribute(:website, 'example.com') }

      it { should == link_to("http://" + user.website, "http://" + user.website, :target => "_blank", :rel => "nofollow") }
    end
  end
end
