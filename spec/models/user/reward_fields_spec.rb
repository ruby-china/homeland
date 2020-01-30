# frozen_string_literal: true

require "rails_helper"

describe User, type: :model do
  describe "RewardFields" do
    let(:user) { create(:user) }

    it "should work" do
      params = {
        alipay: "alipay111",
        wechat: "wechat111"
      }
      assert_equal false, user.reward_enabled?
      user.update_reward_fields(params)
      assert_equal true, user.reward_enabled?
      assert_equal params, user.reward_fields
      assert_equal "wechat111", user.reward_field(:wechat)
      assert_equal "wechat111", user.reward_field("wechat")
      assert_equal "alipay111", user.reward_field("alipay")
      assert_nil user.reward_field(:ddd)
      assert_nil user.reward_field(:facebook)
      assert_equal "微信", User.reward_field_label(:wechat)
      assert_equal "支付宝", User.reward_field_label(:alipay)
    end
  end
end
