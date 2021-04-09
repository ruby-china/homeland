# frozen_string_literal: true

require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  attr_accessor :user

  test "contacts" do
    @user.create_profile(contacts: {weibo: "huacnlee", twitter: "huacnlee"})
    assert_equal({weibo: "huacnlee", twitter: "huacnlee"}.as_json, @user.contacts)
  end

  test "#contact_field_prefix" do
    assert_equal "https://weibo.com/", Profile.contact_field_prefix(:weibo)
    assert_equal "https://facebook.com/", Profile.contact_field_prefix(:facebook)
    assert_equal "https://instagram.com/", Profile.contact_field_prefix(:instagram)
    assert_equal "https://dribbble.com/", Profile.contact_field_prefix(:dribbble)
    assert_equal "https://www.douban.com/people/", Profile.contact_field_prefix(:douban)
    assert_nil Profile.contact_field_prefix(:bb)
  end

  test "#has_field?" do
    assert_equal true, Profile.has_field?(:weibo)
    assert_equal true, Profile.has_field?(:facebook)
    assert_equal false, Profile.has_field?(:weibo1)
  end

  test "#contact_field_label" do
    assert_equal "Facebook", Profile.contact_field_label(:facebook)
    assert_equal "Dribbble", Profile.contact_field_label(:dribbble)
  end

  test "#reward_field_label" do
    assert_equal "Wechat", Profile.reward_field_label(:wechat)
    assert_equal "Alipay", Profile.reward_field_label(:alipay)
  end
end
