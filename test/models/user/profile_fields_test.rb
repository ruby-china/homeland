# frozen_string_literal: true

require "test_helper"

class User::ProfileFiledsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  attr_accessor :user

  test "profile_field" do
    params = {
      weibo: "weibo1",
      douban: "douban1",
      dribbble: "dribbble1"
    }
    user.update_profile_fields(params)
    assert_equal params.as_json, user.contacts
    assert_equal "weibo1", user.profile_field(:weibo)
    assert_equal "weibo1", user.profile_field("weibo")
    assert_equal "douban1", user.profile_field("douban")
    assert_nil user.profile_field(:ddd)
    assert_nil user.profile_field(:facebook)
    assert_equal "https://weibo.com/weibo1", user.full_profile_field(:weibo)
  end
end
