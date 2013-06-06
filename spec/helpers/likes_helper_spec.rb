# coding: utf-8
require "spec_helper"

describe LikesHelper do
  describe "likeable_tag" do
    let(:user) { Factory :user }
    let(:topic) { Factory :topic }

    it "should run with nil param" do
      helper.stub(:current_user).and_return(nil)
      helper.likeable_tag(nil).should == ""
    end

    it "should result when logined user liked" do
      helper.stub(:current_user).and_return(user)
      topic.stub(:liked_by_user?).and_return(true)
      helper.likeable_tag(topic).should == %(<a class=\"likeable\" data-count=\"0\" data-id=\"1\" data-state=\"liked\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"取消喜欢\"><i class=\"icon small_liked\"></i> <span>喜欢</span></a>)
      topic.stub!(:likes_count).and_return(3)
      helper.likeable_tag(topic).should == %(<a class=\"likeable\" data-count=\"3\" data-id=\"1\" data-state=\"liked\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"取消喜欢\"><i class=\"icon small_liked\"></i> <span>3人喜欢</span></a>)
    end

    it "should result when unlogin user" do
      helper.stub(:current_user).and_return(nil)
      helper.likeable_tag(topic).should == %(<a class=\"likeable\" data-count=\"0\" data-id=\"1\" data-state=\"\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"喜欢\"><i class=\"icon small_like\"></i> <span>喜欢</span></a>)
    end

    it "should result with no_cache params" do
      str = %(<a class=\"likeable\" data-count=\"0\" data-id=\"1\" data-state=\"\" data-type=\"Topic\" href=\"#\" onclick=\"return App.likeable(this);\" rel=\"twipsy\" title=\"喜欢\"><i class=\"icon small_like\"></i> <span>喜欢</span></a>)
      helper.likeable_tag(topic, :cache => true).should == str
      helper.stub(:current_user).and_return(user)
      helper.likeable_tag(topic, :cache => true).should == str
    end
  end
end
