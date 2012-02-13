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
      helper.likeable_tag(topic).should == %(<a href="#" class="likeable" data-id="#{topic.id}" data-state="liked" data-type="#{topic.class}" onclick="return App.likeable(this);" rel="twipsy" title="取消喜欢"><i class="icon small_liked"></i> <span>#{topic.likes_count}人喜欢</span></a>)
    end

    it "should result when unlogin user" do
      helper.stub(:current_user).and_return(nil)
      helper.likeable_tag(topic).should == %(<a href="#" class="likeable" data-id="#{topic.id}" data-state="" data-type="#{topic.class}" onclick="return App.likeable(this);" rel="twipsy" title="喜欢(可用于收藏此贴)"><i class="icon small_like"></i> <span>#{topic.likes_count}人喜欢</span></a>)
    end
  end
end
