# coding: utf-8
require "rails_helper"

describe UsersHelper, :type => :helper do
  describe "user_avatar_width_for_size" do
    it "should calculate avatar width correctly" do
      expect(helper.user_avatar_width_for_size(:normal)).to eq(48)
      expect(helper.user_avatar_width_for_size(:small)).to eq(16)
      expect(helper.user_avatar_width_for_size(:large)).to eq(64)
      expect(helper.user_avatar_width_for_size(:big)).to eq(120)
      expect(helper.user_avatar_width_for_size(233)).to eq(233)
    end
  end

  describe "user_name_tag" do
    it "should result right html in normal" do
      user = Factory(:user)
      expect(helper.user_name_tag(user)).to eq(link_to(user.login, user_path(user.login), 'data-name' => user.name))
    end

    it "should result right html with string param and downcase url" do
      login = "Monster"
      expect(helper.user_name_tag(login)).to eq(link_to(login, user_path(login.downcase), 'data-name' => login))
    end

    it "should result empty with nil param" do
      expect(helper.user_name_tag(nil)).to eq("匿名")
    end
  end

  describe "user personal website" do
    let(:user) { Factory(:user, :website => 'http://example.com') }
    subject { helper.render_user_personal_website(user) }

    it { is_expected.to eq(link_to(user.website, user.website, :target => "_blank", :class => "url", :rel => "nofollow")) }

    context "url without protocal" do
      before { user.update_attribute(:website, 'example.com') }

      it { is_expected.to eq(link_to("http://" + user.website, "http://" + user.website, :class => "url", :target => "_blank", :rel => "nofollow")) }
    end
  end
end
