# frozen_string_literal: true

require "test_helper"

class User::RewardFieldsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  attr_accessor :user

  test "RewardFields" do
    params = {
      alipay: "alipay111",
      wechat: "wechat111"
    }
    assert_equal false, user.reward_enabled?
    user.update_reward_fields(params)
    assert_equal params.as_json, user.rewards
    assert_equal true, user.reward_enabled?
    assert_equal "wechat111", user.reward_field(:wechat)
    assert_equal "wechat111", user.reward_field("wechat")
    assert_equal "alipay111", user.reward_field("alipay")
    assert_nil user.reward_field(:ddd)
    assert_nil user.reward_field(:facebook)
  end
end
