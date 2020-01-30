# frozen_string_literal: true

require "rails_helper"

describe User, type: :model do
  describe "ProfileFields" do
    let(:user) { create(:user) }
    describe "#profile_field_prefix" do
      it "should work" do
        assert_equal "https://weibo.com/", User.profile_field_prefix(:weibo)
        assert_equal "https://facebook.com/", User.profile_field_prefix(:facebook)
        assert_equal "https://instagram.com/", User.profile_field_prefix(:instagram)
        assert_equal "https://dribbble.com/", User.profile_field_prefix(:dribbble)
        assert_equal "https://www.douban.com/people/", User.profile_field_prefix(:douban)
        assert_nil User.profile_field_prefix(:bb)
      end
    end

    describe "InstaceMehtods" do
      it "should work" do
        params = {
          weibo: "weibo1",
          douban: "douban1",
          dribbble: "dribbble1"
        }
        user.update_profile_fields(params)
        assert_equal params, user.profile_fields
        assert_equal "weibo1", user.profile_field(:weibo)
        assert_equal "weibo1", user.profile_field("weibo")
        assert_equal "douban1", user.profile_field("douban")
        assert_nil user.profile_field(:ddd)
        assert_nil user.profile_field(:facebook)
        assert_equal "https://weibo.com/weibo1", user.full_profile_field(:weibo)
      end
    end
  end
end
