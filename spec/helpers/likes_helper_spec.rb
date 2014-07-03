# coding: utf-8
require "rails_helper"

describe LikesHelper, :type => :helper do
  describe "likeable_tag" do
    let(:user) { Factory :user }
    let(:topic) { Factory :topic }

    it "should run with nil param" do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.likeable_tag(nil)).to eq("")
    end

    it "should result when logined user liked" do
      allow(helper).to receive(:current_user).and_return(user)
      allow(topic).to receive(:liked_by_user?).and_return(true)
      expect(helper.likeable_tag(topic)).to eq(%(<a class=\"likeable\" data-count=\"0\" data-id=\"1\" data-state=\"liked\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"取消喜欢\"><i class=\"icon small_liked\"></i> <span>喜欢</span></a>))
      allow(topic).to receive(:likes_count).and_return(3)
      expect(helper.likeable_tag(topic)).to eq(%(<a class=\"likeable\" data-count=\"3\" data-id=\"1\" data-state=\"liked\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"取消喜欢\"><i class=\"icon small_liked\"></i> <span>3 人喜欢</span></a>))
    end

    it "should result when unlogin user" do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.likeable_tag(topic)).to eq(%(<a class=\"likeable\" href=\"/account/sign_in\"><i class=\"icon small_like\"></i> <span>喜欢</span></a>))
    end

    it "should result with no_cache params" do
      str = %(<a class=\"likeable\" data-count=\"0\" data-id=\"1\" data-state=\"\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"喜欢\"><i class=\"icon small_like\"></i> <span>喜欢</span></a>)
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.likeable_tag(topic, :cache => true)).to eq(str)
    end
  end
end
