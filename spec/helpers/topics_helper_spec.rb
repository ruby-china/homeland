# frozen_string_literal: true

require "rails_helper"

describe TopicsHelper, type: :helper do
  describe "topic_favorite_tag" do
    let(:user) { create :user }
    let(:topic) { create :topic }

    it "should run with nil param" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal "", helper.topic_favorite_tag(nil)
    end

    it "should result when logined user did not favorite topic" do
      allow(user).to receive(:favorite_topic?).and_return(false)
      allow(helper).to receive(:current_user).and_return(user)
      res = helper.topic_favorite_tag(topic)
      assert_equal "<a title=\"收藏\" class=\"bookmark \" data-id=\"1\" href=\"#\"><i class=\"fa fa-bookmark\"></i> 收藏</a>", res
    end

    it "should result when logined user favorited topic" do
      allow(user).to receive(:favorite_topic?).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
      assert_equal "<a title=\"取消收藏\" class=\"bookmark active\" data-id=\"1\" href=\"#\"><i class=\"fa fa-bookmark\"></i> 收藏</a>", helper.topic_favorite_tag(topic)
    end

    it "should result blank when unlogin user" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal "", helper.topic_favorite_tag(topic)
    end
  end

  describe "topic_title_tag" do
    let(:topic) { create :topic, title: "test title" }
    let(:user) { create :user }

    it "should return topic_was_deleted without a topic" do
      assert_equal t("topics.topic_was_deleted"), helper.topic_title_tag(nil)
    end

    it "should return title with a topic" do
      assert_equal "<a title=\"#{topic.title}\" href=\"/topics/#{topic.id}\">#{topic.title}</a>", helper.topic_title_tag(topic)
    end
  end

  describe "topic_follow_tag" do
    let(:topic) { create :topic }
    let(:user) { create :user }

    it "should return empty when current_user is nil" do
      allow(helper).to receive(:current_user).and_return(nil)
      assert_equal "", helper.topic_follow_tag(topic)
    end

    it "should return empty when is owner" do
      allow(helper).to receive(:current_user).and_return(topic.user)
      assert_equal "", helper.topic_follow_tag(topic)
    end

    it "should return empty when topic is nil" do
      allow(helper).to receive(:current_user).and_return(user)
      assert_equal "", helper.topic_follow_tag(nil)
    end

    context "was unfollow" do
      it "should work" do
        allow(helper).to receive(:current_user).and_return(user)
        assert_equal "<a data-id=\"#{topic.id}\" class=\"follow\" href=\"#\"><i class=\"fa fa-eye\"></i> 关注</a>", helper.topic_follow_tag(topic)
      end
    end

    context "was active" do
      it "should work" do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive(:follow_topic?).and_return(true)
        assert_equal "<a data-id=\"#{topic.id}\" class=\"follow active\" href=\"#\"><i class=\"fa fa-eye\"></i> 关注</a>", helper.topic_follow_tag(topic)
      end
    end
  end
end
